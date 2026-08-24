# rbs_inline: enabled

require "tmpdir"
require "fileutils"
require "open3"

# Runs submitted Python code against a problem's test cases and returns one of the seven
# verdicts defined in Art. 26 of the regulation.
#
# Sandbox rationale: docs/adr/0004-execucao-em-conteiner-descartavel.md
# Output comparison: docs/adr/0003-saida-esperada-gerada-comparacao-exata.md
class Judge
  IMAGE      = "python:3.12-slim"
  TIME_LIMIT = 5
  MEMORY     = "256m"

  CE_EXIT  = 100
  TLE_EXIT = 124
  OOM_EXIT = 137

  # What the container runs: compile once, then one process per case. A frozen literal on
  # purpose — the limits cross into the container as environment variables, so nothing this
  # process holds is ever spliced into a shell.
  SCRIPT = <<~SH.freeze
    python -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' \
      /code/solution.py 2>/out/ce.txt || exit "$CE_EXIT"
    for input in /code/cases/*.in; do
      n=$(basename "$input" .in)
      timeout "$TIME_LIMIT" python /code/solution.py < "$input" \
        > "/out/$n.out" 2> "/out/$n.err"
      status=$?
      echo "$status" > "/out/$n.code"
      [ "$status" -eq 0 ] || exit 0
    done
  SH

  # Raised when code meant to produce expected output does not finish cleanly.
  class Failed < StandardError
    attr_reader :verdict #: String

    #: (String, ?String?) -> void
    def initialize(verdict, message = nil)
      @verdict = verdict
      super(message.nil? || message.strip.empty? ? verdict : message)
    end
  end

  # The outcome of judging one submission.
  class Result
    attr_reader :verdict     #: String
    attr_reader :failed_case #: Integer?
    attr_reader :message     #: String?

    #: (verdict: String, ?failed_case: Integer?, ?message: String?) -> void
    def initialize(verdict:, failed_case: nil, message: nil)
      @verdict = verdict
      @failed_case = failed_case
      @message = message
    end

    #: () -> bool
    def accepted? = verdict == "AC"

    #: () -> String
    def to_s = failed_case ? "#{verdict} (case #{failed_case})" : verdict
  end

  #: (?image: String, ?time_limit: Integer, ?memory: String) -> void
  def initialize(image: IMAGE, time_limit: TIME_LIMIT, memory: MEMORY)
    @image = image
    @time_limit = time_limit
    @memory = memory
  end

  # Judges code against cases, each a hash of :input and :expected.
  #: (String, Array[Hash[Symbol, String]]) -> Result
  def judge(code, cases)
    raise ArgumentError, "no test cases" if cases.empty?

    Dir.mktmpdir("judge") do |dir|
      prepare(dir, code, cases)
      _, stderr, _ = run_container(dir)
      collect(dir, cases, stderr)
    end
  end

  # Runs code against one input and returns exactly the bytes it printed. This is how a
  # test case gets its expected output — it is generated, never typed (ADR-0003).
  #: (String, String) -> String
  def run(code, input)
    Dir.mktmpdir("judge") do |dir|
      prepare(dir, code, [ { input: input } ])
      _, stderr, _ = run_container(dir)
      output(dir, stderr)
    end
  end

  private

  # Writes the submission and every case input into the directory shared with the container.
  # Written as bytes: a case input arrives from a binary column, and transcoding it would
  # raise on the first accent — the reasoning of ADR-0003 applied to the filesystem.
  #: (String, String, Array[Hash[Symbol, String]]) -> void
  def prepare(dir, code, cases)
    FileUtils.mkdir_p([ "#{dir}/code/cases", "#{dir}/out" ])
    File.binwrite("#{dir}/code/solution.py", code)
    cases.each_with_index do |c, i|
      File.binwrite("#{dir}/code/cases/#{format('%03d', i + 1)}.in", c[:input])
    end
    FileUtils.chmod(0o777, "#{dir}/out")
  end

  # Executes the submission in a throwaway container.
  #: (String) -> [ String, String, Process::Status ]
  def run_container(dir)
    Open3.capture3(
      "docker", "run", "--rm",
      "--network=none",
      "--memory=#{@memory}", "--memory-swap=#{@memory}",
      "--cpus=1", "--pids-limit=64",
      "--read-only", "--tmpfs", "/tmp",
      "--user", "65534:65534",
      "--security-opt=no-new-privileges",
      "-e", "PYTHONDONTWRITEBYTECODE=1",
      "-e", "TIME_LIMIT=#{@time_limit}",
      "-e", "CE_EXIT=#{CE_EXIT}",
      "-v", "#{dir}/code:/code:ro",
      "-v", "#{dir}/out:/out",
      @image, "sh", "-c", SCRIPT
    )
  end

  # Reads the container output and returns the verdict of the first case that is not AC.
  # The docker stderr goes into the message when the container left no trace: without it,
  # an infrastructure failure (mount denied, daemon down) is indistinguishable from a
  # crashing submission.
  #: (String, Array[Hash[Symbol, String]], String) -> Result
  def collect(dir, cases, docker_stderr)
    ce = "#{dir}/out/ce.txt"
    return Result.new(verdict: "CE", message: File.read(ce)) if File.exist?(ce) && !File.read(ce).empty?

    cases.each_with_index do |c, i|
      n = format("%03d", i + 1)
      status_file = "#{dir}/out/#{n}.code"

      unless File.exist?(status_file)
        return Result.new(verdict: "RE", failed_case: i + 1,
                          message: no_trace_message(docker_stderr, "container exited before this case"))
      end

      status = File.read(status_file).strip.to_i
      unless status.zero?
        return Result.new(verdict: runtime_verdict(status), failed_case: i + 1,
                          message: File.read("#{dir}/out/#{n}.err"))
      end

      verdict = compare(File.read("#{dir}/out/#{n}.out"), c[:expected])
      return Result.new(verdict: verdict, failed_case: i + 1) unless verdict == "AC"
    end

    Result.new(verdict: "AC")
  end

  # Maps a non-zero exit status to its verdict.
  #: (Integer) -> String
  def runtime_verdict(status)
    case status
    when TLE_EXIT then "TLE"
    when OOM_EXIT then "MLE"
    else "RE"
    end
  end

  # Prefers what docker printed over a generic message when the container left no files.
  #: (String, String) -> String
  def no_trace_message(docker_stderr, fallback)
    docker_stderr.strip.empty? ? fallback : docker_stderr.strip
  end

  # Compares actual output against expected byte by byte, distinguishing WA from PE.
  # Comparison is on bytes because the expected output arrives from a binary column and
  # Ruby answers that a BINARY string and a UTF-8 string with the same bytes differ.
  # The reasoning of ADR-0003 applied to Ruby: nothing but the bytes decides equality.
  #: (String, String) -> String
  def compare(actual, expected)
    return "AC" if actual.b == expected.b
    return "PE" if normalize(actual) == normalize(expected)

    "WA"
  end

  # Strips trailing whitespace from each line and from the end of the output.
  #: (String) -> String
  def normalize(text)
    text.b.lines.map(&:rstrip).join("\n").rstrip
  end

  # Reads the single case's output, refusing anything that did not exit cleanly. Read as
  # bytes: what is stored must be what the program printed, down to the byte (ADR-0003).
  #: (String, String) -> String
  def output(dir, docker_stderr)
    ce = "#{dir}/out/ce.txt"
    raise Failed.new("CE", File.read(ce)) if File.exist?(ce) && !File.read(ce).empty?

    status_file = "#{dir}/out/001.code"
    unless File.exist?(status_file)
      raise Failed.new("RE", no_trace_message(docker_stderr, "container exited before running"))
    end

    status = File.read(status_file).strip.to_i
    unless status.zero?
      raise Failed.new(runtime_verdict(status), File.read("#{dir}/out/001.err"))
    end

    File.binread("#{dir}/out/001.out")
  end
end
