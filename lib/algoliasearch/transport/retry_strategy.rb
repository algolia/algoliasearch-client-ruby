module Algoliasearch
  # Class RetryStatregy
  class RetryStrategy
    include RetryOutcomeType
    # Initializes the retry strategy
    #
    # @param config [SearchConfig] config which contains the hosts
    def initialize(config)
      @hosts = config.custom_hosts || config.default_hosts
    end

    # Retrieves the tryable hosts
    #
    # @param call_type [binary] type of the host
    #
    # @return [Array] list of StatefulHost
    #
    def get_tryable_hosts(call_type)
      reset_expired_hosts

      if @hosts.any? { |host| host.up && has_flag(host.accept, call_type) }
        @hosts.select { |host| host.up && has_flag(host.accept, call_type) }
      else
        @hosts.each do |host|
          reset(host) if has_flag(host.accept, call_type)
        end
        @hosts
      end
    end

    # Decides on the outcome of the request
    #
    # @param tryable_host [StatefulHost] host to test against
    # @param http_response_code [Integer] http response code
    # @param is_timed_out [Boolean] whether or not the request timed out
    #
    # @return [Binary] retry outcome code
    #
    def decide(tryable_host, http_response_code, is_timed_out)
      if !is_timed_out && is_success(http_response_code)
        tryable_host.up = true
        tryable_host.last_use = Time.now
        SUCCESS
      elsif !is_timed_out && is_retryable(http_response_code)
        tryable_host.up = false
        tryable_host.last_use = Time.now
        RETRY
      elsif is_timed_out
        RETRY
      else
        FAILURE
      end
    end

    private

    #
    # @param http_response_code [Integer]
    #
    # @return [Boolean]
    #
    def is_success(http_response_code)
      (http_response_code.to_i / 100).floor == 2
    end

    #
    # @param http_response_code [Integer]
    #
    # @return [Boolean]
    #
    def is_retryable(http_response_code)
      (http_response_code.to_i / 100).floor != 2 && (http_response_code.to_i / 100).floor != 4
    end

    #
    # Iterates in the hosts list and reset the ones that are down
    #
    def reset_expired_hosts
      @hosts.each do |host|
        host_last_usage = Time.now - host.last_use
        reset(host) if !host.up && host_last_usage.to_i > StatefulHost::TTL
      end
    end

    #
    # Reset a single host
    #
    # @param host [StatefulHost]
    #
    def reset(host)
      host.up = true
      host.retry_count = 0
      host.last_use = Time.now
    end

    #
    # Make a binary check to know whether the item contains the flag
    #
    # @param item [binary] item to check
    # @param flag [binary] flag to find in the item
    #
    # @return [Boolean]
    #
    def has_flag(item, flag)
      (item & (1 << (flag - 1))) > 0
    end
  end
end
