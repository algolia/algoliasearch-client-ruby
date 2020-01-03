module Algoliasearch
  class UserAgent
    attr_reader :value
    def initialize
      @value = ["Algolia for Ruby (#{::Algolia::VERSION})", "Ruby (#{RUBY_VERSION})"]
    end

    def add(segment, version)
      @value += "; #{segment} (#{version})"
    end
  end
end
