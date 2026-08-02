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
      run_container(dir)
      collect(dir, cases)
    end
  end

  private

  # Writes the submission and every case input into the directory shared with the container.
  #: (String, String, Array[Hash[Symbol, String]]) -> void
  def prepare(dir, code, cases)
    FileUtils.mkdir_p([ "#{dir}/code/cases", "#{dir}/out" ])
    File.write("#{dir}/code/solution.py", code)
    cases.each_with_index do |c, i|
      File.write("#{dir}/code/cases/#{format('%03d', i + 1)}.in", c[:input])
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
      "-v", "#{dir}/code:/code:ro",
      "-v", "#{dir}/out:/out",
      @image, "sh", "-c", container_script
    )
  end

  # Builds the shell script the container runs: compile once, then one process per case.
  #: () -> String
  def container_script
    <<~SH
      python -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' \
        /code/solution.py 2>/out/ce.txt || exit #{CE_EXIT}
      for input in /code/cases/*.in; do
        n=$(basename "$input" .in)
        timeout #{@time_limit} python /code/solution.py < "$input" \
          > "/out/$n.out" 2> "/out/$n.err"
        status=$?
        echo "$status" > "/out/$n.code"
        [ "$status" -eq 0 ] || exit 0
      done
    SH
  end

  # Reads the container output and returns the verdict of the first case that is not AC.
  #: (String, Array[Hash[Symbol, String]]) -> Result
  def collect(dir, cases)
    ce = "#{dir}/out/ce.txt"
    return Result.new(verdict: "CE", message: File.read(ce)) if File.exist?(ce) && !File.read(ce).empty?

    cases.each_with_index do |c, i|
      n = format("%03d", i + 1)
      status_file = "#{dir}/out/#{n}.code"

      unless File.exist?(status_file)
        return Result.new(verdict: "RE", failed_case: i + 1,
                          message: "container exited before this case")
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

  # Compares actual output against expected, distinguishing WA from PE.
  #: (String, String) -> String
  def compare(actual, expected)
    return "AC" if actual == expected
    return "PE" if normalize(actual) == normalize(expected)

    "WA"
  end

  # Strips trailing whitespace from each line and from the end of the output.
  #: (String) -> String
  def normalize(text)
    text.lines.map(&:rstrip).join("\n").rstrip
  end
end
