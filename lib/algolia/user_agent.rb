module Algolia
  class UserAgent
    attr_accessor :value

    def initialize
      @value = "Algolia for Ruby (#{VERSION}); Ruby (#{RUBY_VERSION})"
    end

    # Adds a segment to the UserAgent
    #
    def add(segment, version = nil)
      if version.nil?
        @value += format("; %<segment>s", segment: segment)
      else
        @value += format("; %<segment>s (%<version>s)", segment: segment, version: version)
      end

      self
    end
  end
end
