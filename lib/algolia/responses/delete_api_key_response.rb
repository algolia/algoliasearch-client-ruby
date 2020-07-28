module Algolia
  class DeleteApiKeyResponse < BaseResponse
    attr_reader :raw_response

    def initialize(client, response, key)
      @client       = client
      @raw_response = response
      @key          = key
      @done         = false
    end

    def wait(opts = {})
      retries_count = 1

      until @done
        begin
          @client.get_api_key(@key, opts)
        rescue StandardError => e
          @done = e.code == 404

          unless @done
            retries_count    += 1
            time_before_retry = retries_count * Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY
            sleep(time_before_retry / 1000)
          end
        end
      end

      self
    end
  end
end
