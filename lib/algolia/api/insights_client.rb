# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

module Algolia
  class InsightsClient
    attr_accessor :api_client

    def initialize(config = nil)
      raise "`config` is missing." if config.nil?
      raise "`app_id` is missing." if config.app_id.nil? || config.app_id == ""
      raise "`api_key` is missing." if config.api_key.nil? || config.api_key == ""

      @api_client = Algolia::ApiClient.new(config)
    end

    def self.create(app_id, api_key, region = nil, opts = {})
      hosts = []
      regions = ["de", "us"]

      if region.is_a?(Hash) && (opts.nil? || opts.empty?)
        opts = region
        region = nil
      end

      if !region.nil? && (!region.is_a?(String) || !regions.include?(region))
        raise "`region` must be one of the following: #{regions.join(", ")}"
      end

      hosts <<
        Transport::StatefulHost.new(
          region.nil? ? "insights.algolia.io" : "insights.{region}.algolia.io".sub!("{region}", region),
          accept: CallType::READ | CallType::WRITE
        )

      config = Algolia::Configuration.new(app_id, api_key, hosts, "Insights", opts)
      create_with_config(config)
    end

    def self.create_with_config(config)
      new(config)
    end

    # Helper method to switch the API key used to authenticate the requests.
    #
    # @param api_key [String] the new API key to use.
    # @return [void]
    def set_client_api_key(api_key)
      @api_client.set_client_api_key(api_key)
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def custom_delete_with_http_info(path, parameters = nil, request_options = {})
      # verify the required parameter 'path' is set
      if @api_client.config.client_side_validation && path.nil?
        raise ArgumentError, "Parameter `path` is required when calling `custom_delete`."
      end

      path = "/{path}".sub("{" + "path" + "}", path.to_s)
      query_params = {}
      query_params = query_params.merge(parameters) unless parameters.nil?
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"InsightsClient.custom_delete",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:DELETE, path, new_options)
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_delete(path, parameters = nil, request_options = {})
      response = custom_delete_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def custom_get_with_http_info(path, parameters = nil, request_options = {})
      # verify the required parameter 'path' is set
      if @api_client.config.client_side_validation && path.nil?
        raise ArgumentError, "Parameter `path` is required when calling `custom_get`."
      end

      path = "/{path}".sub("{" + "path" + "}", path.to_s)
      query_params = {}
      query_params = query_params.merge(parameters) unless parameters.nil?
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"InsightsClient.custom_get",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_get(path, parameters = nil, request_options = {})
      response = custom_get_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def custom_post_with_http_info(path, parameters = nil, body = nil, request_options = {})
      # verify the required parameter 'path' is set
      if @api_client.config.client_side_validation && path.nil?
        raise ArgumentError, "Parameter `path` is required when calling `custom_post`."
      end

      path = "/{path}".sub("{" + "path" + "}", path.to_s)
      query_params = {}
      query_params = query_params.merge(parameters) unless parameters.nil?
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(body)

      new_options = request_options.merge(
        :operation => :"InsightsClient.custom_post",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_post(path, parameters = nil, body = nil, request_options = {})
      response = custom_post_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def custom_put_with_http_info(path, parameters = nil, body = nil, request_options = {})
      # verify the required parameter 'path' is set
      if @api_client.config.client_side_validation && path.nil?
        raise ArgumentError, "Parameter `path` is required when calling `custom_put`."
      end

      path = "/{path}".sub("{" + "path" + "}", path.to_s)
      query_params = {}
      query_params = query_params.merge(parameters) unless parameters.nil?
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(body)

      new_options = request_options.merge(
        :operation => :"InsightsClient.custom_put",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:PUT, path, new_options)
    end

    # This method allow you to send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \&quot;/1\&quot; must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_put(path, parameters = nil, body = nil, request_options = {})
      response = custom_put_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # Deletes all events related to the specified user token from events metrics and analytics. The deletion is asynchronous, and processed within 48 hours. To delete a personalization user profile, see &#x60;Delete a user profile&#x60; in the Personalization API.

    # @param user_token [String] User token for which to delete all associated events. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def delete_user_token_with_http_info(user_token, request_options = {})
      # verify the required parameter 'user_token' is set
      if @api_client.config.client_side_validation && user_token.nil?
        raise ArgumentError, "Parameter `user_token` is required when calling `delete_user_token`."
      end

      path = "/1/usertokens/{userToken}".sub("{" + "userToken" + "}", Transport.encode_uri(user_token.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"InsightsClient.delete_user_token",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:DELETE, path, new_options)
    end

    # Deletes all events related to the specified user token from events metrics and analytics. The deletion is asynchronous, and processed within 48 hours. To delete a personalization user profile, see `Delete a user profile` in the Personalization API.

    # @param user_token [String] User token for which to delete all associated events. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [nil]
    def delete_user_token(user_token, request_options = {})
      delete_user_token_with_http_info(user_token, request_options)
      nil
    end

    # Sends a list of events to the Insights API.  You can include up to 1,000 events in a single request, but the request body must be smaller than 2&amp;nbsp;MB.

    # @param insights_events [InsightsEvents]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def push_events_with_http_info(insights_events, request_options = {})
      # verify the required parameter 'insights_events' is set
      if @api_client.config.client_side_validation && insights_events.nil?
        raise ArgumentError, "Parameter `insights_events` is required when calling `push_events`."
      end

      path = "/1/events"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(insights_events)

      new_options = request_options.merge(
        :operation => :"InsightsClient.push_events",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # Sends a list of events to the Insights API.  You can include up to 1,000 events in a single request, but the request body must be smaller than 2&nbsp;MB.

    # @param insights_events [InsightsEvents]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [EventsResponse]
    def push_events(insights_events, request_options = {})
      response = push_events_with_http_info(insights_events, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Insights::EventsResponse")
    end

  end
end
