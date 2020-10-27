class MockRequester
  def initialize
    @connection = nil
  end

  def send_request(host, method, path, _body, headers, _timeout, _connect_timeout)
    connection = get_connection(host)
    response   = {
      connection: connection,
      host: host,
      path: path,
      headers: headers,
      method: method,
      status: 200,
      body: '{"hits":[],"nbHits":0,"page":0,"nbPages":1,"hitsPerPage":20,"exhaustiveNbHits":true,"query":"test","params":"query=test","processingTimeMS":1}',
      success: true
    }

    Algolia::Http::Response.new(
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
    @connection = host
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
