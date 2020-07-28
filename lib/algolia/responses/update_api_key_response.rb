module Algolia
  class UpdateApiKeyResponse < BaseResponse
    attr_reader :raw_response

    def initialize(client, response, request_options)
      @client          = client
      @raw_response    = response
      @request_options = request_options
      @done            = false
    end

    def wait(opts = {})
      retries_count = 1

      until @done
        begin
          api_key = @client.get_api_key(@raw_response[:key], opts)
          @done   = @request_options <= api_key
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
