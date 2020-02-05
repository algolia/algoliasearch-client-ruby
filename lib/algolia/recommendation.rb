module Algolia

  class Recommendation
    MIN_RUBY_VERSION = '1.9.0'

    def initialize(app_id, api_key, region = 'us', params = {})
      headers = params[:headers] || {}
      @app_id   = app_id
      @api_key  = api_key
      @url = "https://recommendation.#{region}.algolia.com"
      @headers  = headers.merge({
        Protocol::HEADER_APP_ID  => app_id,
        Protocol::HEADER_API_KEY => api_key,
        'Content-Type'           => 'application/json; charset=utf-8',
        'User-Agent'             => ["Algolia for Ruby (#{::Algolia::VERSION})", "Ruby (#{RUBY_VERSION})"].join('; ')
                                })
    end

    def get_personalization_strategy
      perform_request(:GET, '/1/strategies/personalization')
    end

    def set_personalization_strategy(strategy)
      perform_request(:POST, '/1/events', {}, strategy.to_json)
    end

    private

    def perform_request(method, path, params = {}, data = {})
      http = HTTPClient.new

      url = @url + path

      encoded_params = Hash[params.map { |k, v| [k.to_s, v.is_a?(Array) ? v.to_json : v] }]
      url << "?" + Protocol.to_query(encoded_params)

      response = case method
                 when :POST
                   http.post(url, { :body => data, :header => @headers })
                 when :GET
                   http.get(url, { :header => @headers })
                 end

      if response.code / 100 != 2
        raise AlgoliaProtocolError.new(response.code, "Cannot #{method} to #{url}: #{response.content}")
      end

      JSON.parse(response.content)
    end
  end
end
