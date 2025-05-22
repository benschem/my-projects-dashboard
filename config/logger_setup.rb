# frozen_string_literal: true

require 'logger'
require 'fileutils'

LOG_FILE_PATH = 'logs/my_projects_dashboard.log'

# Logging
module LoggerSetup
  def self.build(environment)
    output = choose_output

    rotate = environment == :production ? 'weekly' : 0
    logger = Logger.new(output, rotate)

    log_level(logger)
    format(logger)

    logger
  end

  def self.choose_output
    if environment == :production
      FileUtils.mkdir_p('logs')
      # Prefer this over: Dir.mkdir('logs') unless File.exist?('logs')
      # Because File.exist? returns true for both files and directories,
      # and Dir.mkdir will raise an exception if 'logs' is a file.
      File.open(LOG_FILE_PATH, 'a+')
    else
      $stdout
    end
  end

  # Log everything in development but only errors in production
  def self.log_level(logger)
    logger.level = environment == :production ? Logger::ERROR : Logger::DEBUG
  end

  # How they should look:
  # 2025-05-22 15:30:10 [pid 12345] INFO: App started successfully
  def self.format(logger)
    logger.formatter = proc do |severity, datetime, _progname, msg|
      pid = Process.pid
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [pid #{pid}] #{severity}: #{msg}\n"
    end
  end
end
