# frozen_string_literal: true

require 'dry/monads/result'
require 'json'

module Ewa
  module Request
    # Project list request parser
    class SelectbyName
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming list requests
      def call
        if @params == {}
          raise StandardError
        end
        Success(
          @params['name']
        )
      rescue StandardError

        raise "#{JSON.parse(@params)}"

        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Name not found'
          )
        )

      end
    end
  end
end
