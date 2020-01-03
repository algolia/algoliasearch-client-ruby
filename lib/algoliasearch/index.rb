module Algoliasearch
  # Class Index
  class Index
    attr_accessor :name, :transporter, :config

    # Initialize an index
    #
    # @param name [String] name of the index
    # @param transporter [nil, Object] transport object used for the connection
    # @param config [nil, Config] a Config object which contains your APP_ID and API_KEY
    #
    def initialize(name, transporter = nil, config = nil)
      self.name = name
      self.transporter = transporter
      self.config = config
    end

    # Perform a search on the index
    #
    # @param query [String] query string provided for the search
    #
    # @return res
    #
    def search(query)
      data = {
        query: query
      }
      res = transporter.post do |req|
        req.url "1/indexes/#{name}/query"
        req.headers['X-Algolia-API-Key'] = config.api_key
        req.headers['X-Algolia-Application-Id'] = config.app_id
        req.body = data.to_json
      end
      res
    end
  end
end
