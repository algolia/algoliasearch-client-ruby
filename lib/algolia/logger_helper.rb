require "logger"

module Algolia
  class LoggerHelper
    # @param debug_file [nil|String] file used to output the logs
    #
    def self.create(debug_file = nil)
      file = debug_file

      if file.nil? && ENV["ALGOLIA_DEBUG"]
        begin
          file = File.new("debug.log", "a+")
        rescue Errno::EACCES, Errno::ENOENT => e
          puts("Failed to open debug.log: #{e.message}. Falling back to $stderr.")
        end
      end

      instance = ::Logger.new(file || $stderr)
      instance.progname = "algolia"
      instance
    end
  end
end
