module Algoliasearch
  class RetryStrategy
    include RetryOutcomeType
    # Initializes the retry strategy
    #
    # @param config [SearchConfig] config which contains the hosts
    def initialize(config)
      @hosts = config.custom_hosts || config.default_hosts
    end

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

    def is_success(http_response_code)
      (http_response_code.to_i / 100).floor == 2
    end

    def is_retryable(http_response_code)
      (http_response_code.to_i / 100).floor != 2 && (http_response_code.to_i / 100).floor != 4
    end

    def reset_expired_hosts
      @hosts.each do |host|
        host_last_usage = Time.now - host.last_use
        reset(host) if !host.up && host_last_usage.to_i > StatefulHost::TTL
      end
    end

    def reset(host)
      host.up = true
      host.retry_count = 0
      host.last_use = Time.now
    end

    def has_flag(item, flag)
      (item & (1 << (flag - 1))) > 0
    end
  end
end
