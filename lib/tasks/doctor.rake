require "open3"

namespace :maratona do
  desc "Diagnoses the judging pipeline: queue processes, failed jobs, Docker, image, a real judge run and the cable database"
  task doctor: :environment do
    report = ->(name, ok, detail = nil) do
      puts "#{ok ? '[ OK ]' : '[FAIL]'} #{name}#{" - #{detail}" if detail}"
    end

    processes = SolidQueue::Process.all.to_a
    fresh = processes.select { |process| process.last_heartbeat_at&.after?(2.minutes.ago) }
    beats = fresh.map { |process| "#{process.kind} (heartbeat #{process.last_heartbeat_at.strftime('%H:%M:%S')})" }
    detail = beats.join(", ").presence ||
      (processes.any? ? "only stale heartbeats - jobs process dead?" : "none registered - is the jobs process running?")
    report.call "Queue processes", fresh.any?, detail

    puts "       Pending submissions: #{Submission.pending.count}"

    failures = SolidQueue::FailedExecution.order(:id)
    if failures.any?
      report.call "Failed jobs", false, "#{failures.count} failed, last error below"
      puts failures.last.error.to_s.lines.first(15).join
    else
      report.call "Failed jobs", true, "none"
    end

    version, error, status = Open3.capture3("docker", "version", "--format", "{{.Server.Version}}")
    report.call "Docker daemon", status.success?, status.success? ? "server #{version.strip}" : error.strip.lines.first

    _, _, status = Open3.capture3("docker", "image", "inspect", Judge::IMAGE)
    report.call "Image #{Judge::IMAGE}", status.success?, status.success? ? nil : "run: docker pull #{Judge::IMAGE}"

    begin
      output = Judge.new.run("print('ok')", "")
      report.call "Judge end-to-end", output.strip == "ok", output.strip == "ok" ? nil : "unexpected output: #{output.inspect}"
    rescue StandardError => e
      report.call "Judge end-to-end", false, "#{e.class}: #{e.message.lines.first(10).join.strip}"
    end

    begin
      SolidCable::Message.count
      report.call "Cable database", true
    rescue StandardError => e
      report.call "Cable database", false, "#{e.class}: #{e.message.lines.first.to_s.strip} - run: rails db:prepare"
    end
  end
end
