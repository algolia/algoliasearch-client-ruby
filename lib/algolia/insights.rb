module Algolia

  class Insights

    def initialize(data)
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @region         = data[:region]

      @headers = {
          Protocol::HEADER_API_KEY => api_key,
          Protocol::HEADER_APP_ID  => application_id,
          'Content-Type'           => 'application/json; charset=utf-8',
          'User-Agent'             => ["Algolia for Ruby (#{::Algolia::VERSION})", "Ruby (#{RUBY_VERSION})"]
                                          .push(data[:user_agent]).compact.join('; ')
      }.push(data[:headers])
    end

    def user(user_token)
      UserInsights.new(self, user_token)
    end

    def send_event(event)
      send_events([event])
    end

    def send_events(events)
      perform_request(:POST, Protocol.add_events_uri, {}, {"events" => events})
    end

    private

    def perform_request(method, path, params = {}, data = {})
      http = HTTPClient.new

      url =  "https://insights.#{@region}.algolia.io#{path}"

      encoded_params = Hash[params.map { |k, v| [k.to_s, v.is_a?(Array) ? v.to_json : v] }]
      url << "?" + Protocol.to_query(encoded_params)

      response = case method
                 when :GET
                   http.get(url, { :header => @headers })
                 when :POST
                   http.post(url, { :body => data, :header => @headers })
                 when :DELETE
                   http.delete(url, { :header => @headers })
                 end

      if response.code / 100 != 2
        raise AlgoliaProtocolError.new(response.code, "Cannot #{method} to #{url}: #{response.content}")
      end

      JSON.parse(response.content)
    end

  end

  class UserInsights

    def initialize(insights, user_token)
      @insights = insights
      @user_token = user_token
    end

    def clicked_object_ids(event_name, index_name, object_ids)
      clicked({
                  'eventName': event_name,
                  'index': index_name,
                  'objectIds': object_ids
              })
    end

    def clicked_object_ids_after_search(event_name, index_name, object_ids, positions, query_id)
      clicked({
                  'eventName': event_name,
                  'index': index_name,
                  'objectIds': object_ids,
                  'positions': positions,
                  'queryId': query_id
              })
    end

    def clicked_filters(event_name, index_name, filters)
      clicked({
                  'eventName': event_name,
                  'index': index_name,
                  'filters': filters
              })
    end

    def converted_object_ids(event_name, index_name, object_ids)
      converted({
                    'eventName': event_name,
                    'index': index_name,
                    'objectIds': object_ids
                })
    end

    def converted_object_ids_after_search(event_name, index_name, object_ids, query_id)
      converted({
                    'eventName': event_name,
                    'index': index_name,
                    'objectIds': object_ids,
                    'queryId': query_id
                })
    end

    def converted_filters(event_name, index_name, filters)
      converted({
                    'eventName': event_name,
                    'index': index_name,
                    'filters': filters
                })
    end

    def viewed_object_ids(event_name, index_name, object_ids)
      viewed({
                 'eventName': event_name,
                 'index': index_name,
                 'objectIds': object_ids
             })
    end

    def viewed_filters(event_name, index_name, filters)
      viewed({
                 'eventName': event_name,
                 'index': index_name,
                 'filters': filters
      })
    end

    private

    def clicked(event)
      event['eventType'] = 'click'
      send_event(event)
    end

    def converted(event)
      event['eventType'] = 'conversion'
      send_event(event)
    end

    def viewed(event)
      event['eventType'] = 'view'
      send_event(event)
    end

    def send_event(event)
      event['userToken'] = @user_token
      @insights.send_event(event)
    end

  end

end
