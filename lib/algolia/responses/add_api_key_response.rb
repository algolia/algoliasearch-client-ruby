module Algolia
  class AddApiKeyResponse < BaseResponse
    attr_reader :raw_response

    # @param client [Search::Client] Algolia Search Client used for verification
    # @param response [Hash] Raw response from the client
    #
    def initialize(client, response)
      @client       = client
      @raw_response = response
      @done         = false
    end

    # Wait for the task to complete
    #
    # @param opts [Hash] contains extra parameters to send with your query
    #
    def wait(opts = {})
      retries_count = 1

      stop_after_seconds = @client.config.wait_task_timeout || opts[:wait_task_timeout]
      start_time = Time.now.to_i

      until @done
        begin
          @client.get_api_key(@raw_response[:key], opts)
          @done = true
        rescue AlgoliaError => e
          if e.code != 404
            raise e
          end

          unless stop_after_seconds.nil?
            elapsed_seconds = Time.now.to_i - start_time
            raise AlgoliaWaitTaskTimedOutError, "waiting for task timed out after #{stop_after_seconds} seconds" if elapsed_seconds >= stop_after_seconds
          end

          retries_count    += 1
          time_before_retry = retries_count * Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY
          sleep(time_before_retry.to_f / 1000)
        end
      end

      self
    end
  end
end
