class MockRequester
  def initialize(config, _logger, _opts)
    @hosts = config.custom_hosts || config.default_hosts

    @connections = {}
    @hosts.each do |host|
      @connections[host.url] = {url: build_url(host), request: {open_timeout: config.connect_timeout}, options: {}}
    end
  end

  def send_request(host, method, path, _body, headers, _timeout)
    connection = get_connection(host)
    response   = {
      connection: connection,
      host: host,
      path: path,
      headers: headers,
      method: method,
      status: 200,
      body: {'hits' => [], 'nbHits' => 0, 'page' => 0, 'nbPages' => 0, 'hitsPerPage' => 20, 'exhaustiveNbHits' => true, 'query' => 'query', 'params' => 'query=query', 'processingTimeMS' => 1},
      success: true
    }

    Algoliasearch::Http::Response.new(
      status: response[:status],
      body: response[:body],
      headers: response[:headers]
    )
  end

  # Retrieve the connection from the @connections
  #
  # @param host [StatefulHost]
  #
  # @return [Faraday::Connection]
  #
  def get_connection(host)
    @connections[host.url]
  end

  # Build url from host, path and parameters
  #
  # @param host [StatefulHost]
  #
  # @return [String]
  #
  def build_url(host)
    host.protocol + host.url
  end
end
