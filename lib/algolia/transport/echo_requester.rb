module Algolia
  module Transport
    class EchoRequester
      def send_request(host, method, path, body, query_params, headers, timeout, connect_timeout)
        Http::Response.new(
          host: host,
          status: 200,
          body: body,
          query_params: query_params,
          headers: headers,
          method: method,
          path: path,
          timeout: timeout,
          connect_timeout: connect_timeout
        )
      end
    end
  end
end
