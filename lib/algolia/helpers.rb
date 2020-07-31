require 'multi_json'

module Helpers
  # Convert an Hash to json
  #
  def to_json(body)
    body.is_a?(String) ? body : MultiJson.dump(body)
  end

  # Converts each key of a hash to symbols
  #
  def symbolize_hash(hash)
    hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
  end

  # Convert params to a full query string
  #
  def handle_params(params)
    params.nil? || params.empty? ? '' : "?#{to_query_string(params)}"
  end

  # Create a query string from params
  #
  def to_query_string(params)
    params.map do |key, value|
      "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
    end.join('&')
  end

  # Convert a json object to an hash
  #
  def json_to_hash(json, symbolize_keys)
    MultiJson.load(json, symbolize_keys: symbolize_keys)
  end

  # Retrieve the given value associated with a key, in string or symbol format
  #
  def get_option(hash, key)
    hash[key.to_sym] || hash[key] || nil
  end

  # Build a path with the given arguments
  #
  def path_encode(path, *args)
    arguments = []
    args.each do |arg|
      arguments.push(CGI.escape(CGI.unescape(arg.to_s)))
    end

    format(path, *arguments)
  end

  def self.included(base)
    base.extend(Helpers)
  end
end
