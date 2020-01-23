module Algoliasearch
  # Class Index
  class Index
    include CallType

    attr_reader :index_name, :transporter, :config

    # Initialize an index
    #
    # @param index_name [String] name of the index
    # @param transporter [nil, Object] transport object used for the connection
    # @param config [nil, Config] a Config object which contains your APP_ID and API_KEY
    #
    def initialize(index_name, transporter, config)
      @index_name  = index_name
      @transporter = transporter
      @config      = config
    end

    # Perform a search on the index
    #
    # @param query [String] query string provided for the search
    #
    # @return res
    #
    def search(query, params = {}, opts = {})
      encoded_params         = Hash[params.map { |k, v| [k.to_s, v.is_a?(Array) ? MultiJson.load(v) : v] }]
      encoded_params[:query] = query
      @transporter.request(
        READ,
        :POST,
        Http::Protocol.search_post_uri(@index_name),
        {params: Http::Protocol.to_query(encoded_params)}.to_json,
        opts
      )
    end

    def save_object(object, object_id = nil, opts = {})
      check_object(object)
      if object_id.nil? || object_id.to_s.empty?
        @transporter.request(
          WRITE,
          :POST,
          Http::Protocol.index_uri(@index_name),
          object.to_json,
          opts
        )
      else
        @transporter.request(
          WRITE,
          :PUT,
          Http::Protocol.object_uri(@index_name, object_id),
          object.to_json,
          opts
        )
      end
    end

    private

    def check_object(object, in_array = false)
      case object
      when Array
        raise ArgumentError, in_array ? 'argument must be an array of objects' : 'argument must not be an array'
      when String, Integer, Float, TrueClass, FalseClass, NilClass
        raise ArgumentError, "argument must be an #{'array of' if in_array} object, got: #{object.inspect}"
      end
    end
  end
end
