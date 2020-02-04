module Algolia
  class LoggerHelper
    def self.create(debug_file = nil)
      file              = debug_file || File.new('debug.log')
      instance          = ::Logger.new file
      instance.progname = 'algolia'
      instance
    end
  end
end
