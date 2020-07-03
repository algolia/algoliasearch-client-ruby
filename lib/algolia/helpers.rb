require 'multi_json'

module Helpers
  # Convert an Hash to json
  #
  def to_json(body)
    body.is_a?(String) ? body : MultiJson.dump(body)
  end

  def to_string(opt)
    opt.is_a?(String) ? opt : opt.to_s
  end

  def symbolize_hash(hash)
    symbolized_hash = hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    symbolized_hash
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

  def json_to_hash(json, symbolize_keys)
    MultiJson.load(json, symbolize_keys: symbolize_keys)
  end

  def get_option(hash, key)
    hash[key.to_sym] || hash[key] || nil
  end

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
