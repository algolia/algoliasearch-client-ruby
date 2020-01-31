module Algoliasearch
  class LoggerHelper
    def self.create(debug_file = nil)
      file              = debug_file || File.new('debug.log')
      instance          = ::Logger.new file
      instance.progname = 'ALGOLIA'
      instance
    end
  end
end
