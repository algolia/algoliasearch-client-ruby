module Algolia
  module Transport
    class EchoRequester
      def send_request(_host, method, path, body, query_params, headers, _timeout, _connect_timeout)
        Http::Response.new(status: 200, body: body, query_params: query_params, headers: headers, method: method, path: path)
      end
    end
  end
end
