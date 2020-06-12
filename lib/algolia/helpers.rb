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

  def json_to_hash(json)
    MultiJson.load(json)
  end

  def get_option(hash, key)
    hash[key.to_sym] || {}
  end

  def path_encode(path, *args)
    arguments = []
    args.each do |arg|
      arguments.push(CGI.escape(CGI.unescape(arg.to_s)))
    end

    format(path, *arguments)
  end
end
