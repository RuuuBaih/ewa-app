# frozen_string_literal: true

require_relative 'list_request'
require 'http'

module Ewa
  module Gateway
    # Infrastructure to call CodePraise API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def all_rest
        @request.all_rest
      end

      def select_rest(town, min_money, max_money)
        @request.select_rest(town, min_money, max_money)
      end

      def pick_id(rest_id)
        @request.pick_id(rest_id)
      end

      def search_name(rest_name)
        @request.search_name(rest_name)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = config.API_HOST + '/api/v1'
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def all_rest
          call_api('get', ['restaurants'])

        def select_rest(town, min_money, max_money)
          call_api('get', ['restaurants'], 'town' => town, 
                        'min_money' => min_money, 'max_money' => max_money)
        end

        def pick_id(rest_id)
          call_api('get', ['restaurants', 'picks', rest_id])
        end

        def search_name(rest_name)
          call_api('get', ['restaurants', 'searches', rest_name])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .then { |str| str ? '?' + str : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299).freeze

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end