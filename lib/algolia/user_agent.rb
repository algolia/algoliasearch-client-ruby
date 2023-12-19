module Algolia
  class UserAgent
    attr_accessor :value

    def initialize
      @value = "Algolia for Ruby (#{VERSION}); Ruby (#{RUBY_VERSION})"
    end

    # Adds a segment to the UserAgent
    #
    def add(segment, version)
      @value += format('; %<segment>s (%<version>s)', segment: segment, version: version)
    end
  end
end
