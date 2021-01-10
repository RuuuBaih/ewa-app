# frozen_string_literal: true

require 'dry/transaction'
# require 'dry/monads/all'

module Ewa
  module Service
    # filter restaurants based on money
    class ShowAllRests
      include Dry::Transaction
      # include Dry::Monads::Result::Mixin
      step :show_all
      step :reify_rest

      private

      def show_all
        restaurants = Gateway::Api.new(Ewa::App.config).all_rest
        parsed_resp = JSON.parse(restaurants.payload)
        message = parsed_resp['message']
        restaurants.success? ? Success(restaurants.payload) : Failure(message)
      rescue StandardError
        Failure('無法獲取資料 Cannot access db')
      end

      # binding.irb
      def reify_rest(restaurants_json)
        Representer::Restaurants.new(OpenStruct.new)
                                .from_json(restaurants_json)
                                .then { |rest_all| Success(rest_all['rests_infos']) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
