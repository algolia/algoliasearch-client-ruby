# frozen_string_literal: true

# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

module Algolia
  class MonitoringClient
    attr_accessor :api_client

    def initialize(config = nil)
      raise "`config` is missing." if config.nil?
      raise "`app_id` is missing." if config.app_id.nil? || config.app_id == ""
      raise "`api_key` is missing." if config.api_key.nil? || config.api_key == ""

      @api_client = Algolia::ApiClient.new(config)
    end

    def self.create(app_id, api_key, opts = {})
      hosts = []
      hosts << Transport::StatefulHost.new("status.algolia.com", accept: CallType::READ | CallType::WRITE)

      config = Algolia::Configuration.new(app_id, api_key, hosts, "Monitoring", opts)
      create_with_config(config)
    end

    def self.create_with_config(config)
      if config.connect_timeout.nil?
        config.connect_timeout = 2000
      end

      if config.read_timeout.nil?
        config.read_timeout = 5000
      end

      if config.write_timeout.nil?
        config.write_timeout = 30000
      end

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

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
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
        :operation => :"MonitoringClient.custom_delete",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:DELETE, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_delete(path, parameters = nil, request_options = {})
      response = custom_delete_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
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
        :operation => :"MonitoringClient.custom_get",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_get(path, parameters = nil, request_options = {})
      response = custom_get_with_http_info(path, parameters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
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
        :operation => :"MonitoringClient.custom_post",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:POST, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_post(path, parameters = nil, body = nil, request_options = {})
      response = custom_post_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
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
        :operation => :"MonitoringClient.custom_put",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:PUT, path, new_options)
    end

    # This method lets you send requests to the Algolia REST API.

    # @param path [String] Path of the endpoint, for example `1/newFeature`. (required)
    # @param parameters [Hash<String, Object>] Query parameters to apply to the current query.
    # @param body [Object] Parameters to send with the custom request.
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Object]
    def custom_put(path, parameters = nil, body = nil, request_options = {})
      response = custom_put_with_http_info(path, parameters, body, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Object")
    end

    # Retrieves known incidents for the selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_cluster_incidents_with_http_info(clusters, request_options = {})
      # verify the required parameter 'clusters' is set
      if @api_client.config.client_side_validation && clusters.nil?
        raise ArgumentError, "Parameter `clusters` is required when calling `get_cluster_incidents`."
      end

      path = "/1/incidents/{clusters}".sub("{" + "clusters" + "}", Transport.encode_uri(clusters.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_cluster_incidents",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves known incidents for the selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [IncidentsResponse]
    def get_cluster_incidents(clusters, request_options = {})
      response = get_cluster_incidents_with_http_info(clusters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::IncidentsResponse")
    end

    # Retrieves the status of selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_cluster_status_with_http_info(clusters, request_options = {})
      # verify the required parameter 'clusters' is set
      if @api_client.config.client_side_validation && clusters.nil?
        raise ArgumentError, "Parameter `clusters` is required when calling `get_cluster_status`."
      end

      path = "/1/status/{clusters}".sub("{" + "clusters" + "}", Transport.encode_uri(clusters.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_cluster_status",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves the status of selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [StatusResponse]
    def get_cluster_status(clusters, request_options = {})
      response = get_cluster_status_with_http_info(clusters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::StatusResponse")
    end

    # Retrieves known incidents for all clusters.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_incidents_with_http_info(request_options = {})
      path = "/1/incidents"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_incidents",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves known incidents for all clusters.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [IncidentsResponse]
    def get_incidents(request_options = {})
      response = get_incidents_with_http_info(request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::IncidentsResponse")
    end

    # Retrieves average times for indexing operations for selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_indexing_time_with_http_info(clusters, request_options = {})
      # verify the required parameter 'clusters' is set
      if @api_client.config.client_side_validation && clusters.nil?
        raise ArgumentError, "Parameter `clusters` is required when calling `get_indexing_time`."
      end

      path = "/1/indexing/{clusters}".sub("{" + "clusters" + "}", Transport.encode_uri(clusters.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_indexing_time",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves average times for indexing operations for selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [IndexingTimeResponse]
    def get_indexing_time(clusters, request_options = {})
      response = get_indexing_time_with_http_info(clusters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::IndexingTimeResponse")
    end

    # Retrieves the average latency for search requests for selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_latency_with_http_info(clusters, request_options = {})
      # verify the required parameter 'clusters' is set
      if @api_client.config.client_side_validation && clusters.nil?
        raise ArgumentError, "Parameter `clusters` is required when calling `get_latency`."
      end

      path = "/1/latency/{clusters}".sub("{" + "clusters" + "}", Transport.encode_uri(clusters.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_latency",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves the average latency for search requests for selected clusters.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [LatencyResponse]
    def get_latency(clusters, request_options = {})
      response = get_latency_with_http_info(clusters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::LatencyResponse")
    end

    # Retrieves metrics related to your Algolia infrastructure, aggregated over a selected time window.  Access to this API is available as part of the [Premium or Elevate plans](https://www.algolia.com/pricing). You must authenticate requests with the `x-algolia-application-id` and `x-algolia-api-key` headers (using the Monitoring API key).

    # @param metric [Metric] Metric to report.  For more information about the individual metrics, see the description of the API response. To include all metrics, use `*`.  (required)
    # @param period [Period] Period over which to aggregate the metrics:  - `minute`. Aggregate the last minute. 1 data point per 10 seconds. - `hour`. Aggregate the last hour. 1 data point per minute. - `day`. Aggregate the last day. 1 data point per 10 minutes. - `week`. Aggregate the last week. 1 data point per hour. - `month`. Aggregate the last month. 1 data point per day.  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_metrics_with_http_info(metric, period, request_options = {})
      # verify the required parameter 'metric' is set
      if @api_client.config.client_side_validation && metric.nil?
        raise ArgumentError, "Parameter `metric` is required when calling `get_metrics`."
      end
      # verify the required parameter 'period' is set
      if @api_client.config.client_side_validation && period.nil?
        raise ArgumentError, "Parameter `period` is required when calling `get_metrics`."
      end

      path = "/1/infrastructure/{metric}/period/{period}"
        .sub("{" + "metric" + "}", Transport.encode_uri(metric.to_s))
        .sub("{" + "period" + "}", Transport.encode_uri(period.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_metrics",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves metrics related to your Algolia infrastructure, aggregated over a selected time window.  Access to this API is available as part of the [Premium or Elevate plans](https://www.algolia.com/pricing). You must authenticate requests with the `x-algolia-application-id` and `x-algolia-api-key` headers (using the Monitoring API key).

    # @param metric [Metric] Metric to report.  For more information about the individual metrics, see the description of the API response. To include all metrics, use `*`.  (required)
    # @param period [Period] Period over which to aggregate the metrics:  - `minute`. Aggregate the last minute. 1 data point per 10 seconds. - `hour`. Aggregate the last hour. 1 data point per minute. - `day`. Aggregate the last day. 1 data point per 10 minutes. - `week`. Aggregate the last week. 1 data point per hour. - `month`. Aggregate the last month. 1 data point per day.  (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [InfrastructureResponse]
    def get_metrics(metric, period, request_options = {})
      response = get_metrics_with_http_info(metric, period, request_options)
      @api_client.deserialize(
        response.body,
        request_options[:debug_return_type] || "Monitoring::InfrastructureResponse"
      )
    end

    # Test whether clusters are reachable or not.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_reachability_with_http_info(clusters, request_options = {})
      # verify the required parameter 'clusters' is set
      if @api_client.config.client_side_validation && clusters.nil?
        raise ArgumentError, "Parameter `clusters` is required when calling `get_reachability`."
      end

      path = "/1/reachability/{clusters}/probes".sub("{" + "clusters" + "}", Transport.encode_uri(clusters.to_s))
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_reachability",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Test whether clusters are reachable or not.

    # @param clusters [String] Subset of clusters, separated by commas. (required)
    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Hash<String, Hash>]
    def get_reachability(clusters, request_options = {})
      response = get_reachability_with_http_info(clusters, request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Hash<String, Hash>")
    end

    # Retrieves the servers that belong to clusters.  The response depends on whether you authenticate your API request:  - With authentication, the response lists the servers assigned to your Algolia application's cluster.  - Without authentication, the response lists the servers for all Algolia clusters.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_servers_with_http_info(request_options = {})
      path = "/1/inventory/servers"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_servers",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves the servers that belong to clusters.  The response depends on whether you authenticate your API request:  - With authentication, the response lists the servers assigned to your Algolia application's cluster.  - Without authentication, the response lists the servers for all Algolia clusters.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [InventoryResponse]
    def get_servers(request_options = {})
      response = get_servers_with_http_info(request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::InventoryResponse")
    end

    # Retrieves the status of all Algolia clusters and instances.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [Http::Response] the response
    def get_status_with_http_info(request_options = {})
      path = "/1/status"
      query_params = {}
      query_params = query_params.merge(request_options[:query_params]) unless request_options[:query_params].nil?
      header_params = {}
      header_params = header_params.merge(request_options[:header_params]) unless request_options[:header_params].nil?

      post_body = request_options[:debug_body]

      new_options = request_options.merge(
        :operation => :"MonitoringClient.get_status",
        :header_params => header_params,
        :query_params => query_params,
        :body => post_body,
        :use_read_transporter => false
      )

      @api_client.call_api(:GET, path, new_options)
    end

    # Retrieves the status of all Algolia clusters and instances.

    # @param request_options: The request options to send along with the query, they will be merged with the transporter base parameters (headers, query params, timeouts, etc.). (optional)
    # @return [StatusResponse]
    def get_status(request_options = {})
      response = get_status_with_http_info(request_options)
      @api_client.deserialize(response.body, request_options[:debug_return_type] || "Monitoring::StatusResponse")
    end

  end
end
