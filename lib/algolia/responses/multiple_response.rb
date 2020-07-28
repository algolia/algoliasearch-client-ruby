module Algolia
  class MultipleResponse < BaseResponse
    include Enumerable

    def initialize(responses = nil)
      @raw_responses = responses || []
    end

    def last
      @raw_responses[@raw_responses.length - 1]
    end

    def push(response)
      @raw_responses.push(response)
    end

    def wait(opts = {})
      @raw_responses.each do |response|
        response.wait(opts)
      end

      @raw_responses = []

      self
    end

    def each
      @raw_responses.each do |response|
        yield response
      end
    end
  end
end
