module Algolia
  # Optional configuration for chunked helpers that batch records and poll for task completion.
  class ChunkedHelperOptions
    DEFAULT_MAX_RETRIES = 100
    DEFAULT_REPLACE_ALL_OBJECTS_MAX_RETRIES = 800
    attr_reader :max_retries

    def initialize(max_retries: DEFAULT_MAX_RETRIES)
      @max_retries = max_retries
    end

    def self.resolve(options, default_max_retries: DEFAULT_MAX_RETRIES)
      options || new(max_retries: default_max_retries)
    end
  end
end
