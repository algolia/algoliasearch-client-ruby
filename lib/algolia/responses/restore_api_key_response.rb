module Algolia
  class RestoreApiKeyResponse < BaseResponse
    def initialize(client, key)
      @client = client
      @key    = key
      @done   = false
    end

    def wait(opts = {})
      retries_count = 1

      until @done
        begin
          @client.get_api_key(@key, opts)
          @done = true
        rescue StandardError => e
          if e.code != 404
            raise e
          end
          retries_count    += 1
          time_before_retry = retries_count * Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY
          sleep(time_before_retry / 1000)
        end
      end

      self
    end
  end
end
