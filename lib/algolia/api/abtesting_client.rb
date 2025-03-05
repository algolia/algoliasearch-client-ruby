# frozen_string_literal: true

# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

module Algolia
  class AbtestingClient
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

      if opts.nil? || opts[:connect_timeout].nil?
        opts[:connect_timeout] = 2000
      end

      if opts.nil? || opts[:read_timeout].nil?
        opts[:read_timeout] = 5000
      end

      if opts.nil? || opts[:write_timeout].nil?
        opts[:write_timeout] = 30000
      end

      if !region.nil? && (!region.is_a?(String) || !regions.include?(region))
        raise "`region` must be one of the following: #{regions.join(", ")}"
      end

      hosts <<
        Transport::StatefulHost.new(
          region.nil? ? "analytics.algolia.com" : "analytics.{region}.algolia.com".sub("{region}", region),
          accept: CallType::READ | CallType::WRITE
        )

      config = Algolia::Configuration.new(app_id, api_key, hosts, "Abtesting", opts)
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

      self
    end

    def add_user_agent_segment(segment, version = nil)
      @api_client.config.add_user_agent_segment(segment, version)

      self
    end

    # Creates a new A/B test.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param add_ab_tests_request [AddABTestsRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def add_ab_tests_with_http_info(add_ab_tests_request, request_options = {})
      # verify the required parameter 'add_ab_tests_request' is set
      if @api_client.config.client_side_validation && add_ab_tests_request.nil?
        raise ArgumentError, "Parameter `add_ab_tests_request` is required when calling `add_ab_tests`."
      end

      path = "/2/abtests"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(add_ab_tests_request)

      new_options = request_options.merge(
        :operation => :"AbtestingClient.add_ab_tests",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # Creates a new A/B test.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param add_ab_tests_request [AddABTestsRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ABTestResponse]
    def add_ab_tests(add_ab_tests_request, request_options = {})
      response = add_ab_tests_with_http_info(add_ab_tests_request, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ABTestResponse")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
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
        :operation => :"AbtestingClient.custom_delete",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:DELETE, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_delete(path, parameters = nil, request_options = {})
      response = custom_delete_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
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
        :operation => :"AbtestingClient.custom_get",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_get(path, parameters = nil, request_options = {})
      response = custom_get_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
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
        :operation => :"AbtestingClient.custom_post",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_post(path, parameters = nil, body = nil, request_options = {})
      response = custom_post_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
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
        :operation => :"AbtestingClient.custom_put",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:PUT, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, anything after \"/1\" must be specified. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_put(path, parameters = nil, body = nil, request_options = {})
      response = custom_put_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # Deletes an A/B test by its ID.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def delete_ab_test_with_http_info(id, request_options = {})
      # verify the required parameter 'id' is set
      if @api_client.config.client_side_validation && id.nil?
        raise ArgumentError, "Parameter `id` is required when calling `delete_ab_test`."
      end

      path = "/2/abtests/{id}".sub("{" + "id" + "}", Transport.encode_uri(id.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"AbtestingClient.delete_ab_test",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:DELETE, path, new_options)
    end

    # Deletes an A/B test by its ID.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ABTestResponse]
    def delete_ab_test(id, request_options = {})
      response = delete_ab_test_with_http_info(id, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ABTestResponse")
    end

    # Given the traffic percentage and the expected effect size, this endpoint estimates the sample size and duration of an A/B test based on historical traffic.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param estimate_ab_test_request [EstimateABTestRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def estimate_ab_test_with_http_info(estimate_ab_test_request, request_options = {})
      # verify the required parameter 'estimate_ab_test_request' is set
      if @api_client.config.client_side_validation && estimate_ab_test_request.nil?
        raise ArgumentError, "Parameter `estimate_ab_test_request` is required when calling `estimate_ab_test`."
      end

      path = "/2/abtests/estimate"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(estimate_ab_test_request)

      new_options = request_options.merge(
        :operation => :"AbtestingClient.estimate_ab_test",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # Given the traffic percentage and the expected effect size, this endpoint estimates the sample size and duration of an A/B test based on historical traffic.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param estimate_ab_test_request [EstimateABTestRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [EstimateABTestResponse]
    def estimate_ab_test(estimate_ab_test_request, request_options = {})
      response = estimate_ab_test_with_http_info(estimate_ab_test_request, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::EstimateABTestResponse")
    end

    # Retrieves the details for an A/B test by its ID.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_ab_test_with_http_info(id, request_options = {})
      # verify the required parameter 'id' is set
      if @api_client.config.client_side_validation && id.nil?
        raise ArgumentError, "Parameter `id` is required when calling `get_ab_test`."
      end

      path = "/2/abtests/{id}".sub("{" + "id" + "}", Transport.encode_uri(id.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"AbtestingClient.get_ab_test",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves the details for an A/B test by its ID.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ABTest]
    def get_ab_test(id, request_options = {})
      response = get_ab_test_with_http_info(id, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ABTest")
    end

    # Lists all A/B tests you configured for this application.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param offset [Integer] Position of the first item to return. (default to 0)
    # @param limit [Integer] Number of items to return. (default to 10)
    # @param index_prefix [String] Index name prefix. Only A/B tests for indices starting with this string are included in the response.
    # @param index_suffix [String] Index name suffix. Only A/B tests for indices ending with this string are included in the response.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def list_ab_tests_with_http_info(
      offset = nil,
      limit = nil,
      index_prefix = nil,
      index_suffix = nil,
      request_options = {}
    )
      path = "/2/abtests"
      query_params = {}
      query_params[:offset] = offset unless offset.nil?
      query_params[:limit] = limit unless limit.nil?
      query_params[:indexPrefix] = index_prefix unless index_prefix.nil?
      query_params[:indexSuffix] = index_suffix unless index_suffix.nil?
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"AbtestingClient.list_ab_tests",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Lists all A/B tests you configured for this application.
    #
    # Required API Key ACLs:
    #   - analytics
    # @param offset [Integer] Position of the first item to return. (default to 0)
    # @param limit [Integer] Number of items to return. (default to 10)
    # @param index_prefix [String] Index name prefix. Only A/B tests for indices starting with this string are included in the response.
    # @param index_suffix [String] Index name suffix. Only A/B tests for indices ending with this string are included in the response.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ListABTestsResponse]
    def list_ab_tests(offset = nil, limit = nil, index_prefix = nil, index_suffix = nil, request_options = {})
      response = list_ab_tests_with_http_info(offset, limit, index_prefix, index_suffix, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ListABTestsResponse")
    end

    # Schedule an A/B test to be started at a later time.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param schedule_ab_tests_request [ScheduleABTestsRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def schedule_ab_test_with_http_info(schedule_ab_tests_request, request_options = {})
      # verify the required parameter 'schedule_ab_tests_request' is set
      if @api_client.config.client_side_validation && schedule_ab_tests_request.nil?
        raise ArgumentError, "Parameter `schedule_ab_tests_request` is required when calling `schedule_ab_test`."
      end

      path = "/2/abtests/schedule"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body] || @api_client.object_to_http_body(schedule_ab_tests_request)

      new_options = request_options.merge(
        :operation => :"AbtestingClient.schedule_ab_test",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # Schedule an A/B test to be started at a later time.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param schedule_ab_tests_request [ScheduleABTestsRequest]  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ScheduleABTestResponse]
    def schedule_ab_test(schedule_ab_tests_request, request_options = {})
      response = schedule_ab_test_with_http_info(schedule_ab_tests_request, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ScheduleABTestResponse")
    end

    # Stops an A/B test by its ID.  You can't restart stopped A/B tests.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def stop_ab_test_with_http_info(id, request_options = {})
      # verify the required parameter 'id' is set
      if @api_client.config.client_side_validation && id.nil?
        raise ArgumentError, "Parameter `id` is required when calling `stop_ab_test`."
      end

      path = "/2/abtests/{id}/stop".sub("{" + "id" + "}", Transport.encode_uri(id.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"AbtestingClient.stop_ab_test",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # Stops an A/B test by its ID.  You can't restart stopped A/B tests.
    #
    # Required API Key ACLs:
    #   - editSettings
    # @param id [Integer] Unique A/B test identifier. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [ABTestResponse]
    def stop_ab_test(id, request_options = {})
      response = stop_ab_test_with_http_info(id, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Abtesting::ABTestResponse")
    end

  end
end
