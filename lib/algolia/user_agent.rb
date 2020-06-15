module Algolia
  class UserAgent
    attr_accessor :value

    @@value = Defaults::USER_AGENT

    def self.value
      @@value
    end

    def self.reset_to_default
      @@value = Defaults::USER_AGENT
    end

    def self.add(segment, version)
      @@value += format('; %<segment>s (%<version>s)', segment: segment, version: version)
    end
  end
end
