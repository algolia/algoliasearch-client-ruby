module Algolia
  class MultipleIndexBatchIndexingResponse < BaseResponse
    attr_reader :raw_response

    def initialize(client, response)
      @client       = client
      @raw_response = response
      @done         = false
    end

    def wait(opts = {})
      unless @done
        @raw_response[:taskID].each do |index_name, task_id|
          @client.wait_task(index_name, task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        end
      end

      @done = true
      self
    end
  end
end
