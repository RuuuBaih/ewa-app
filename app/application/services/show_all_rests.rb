# frozen_string_literal: true

require 'dry/transaction'
#require 'dry/monads/all'

module Ewa
  module Service
    # filter restaurants based on money
    class ShowAllRests
      include Dry::Transaction
      #include Dry::Monads::Result::Mixin
      step :show_all
      step :reify_rest

      private

      def show_all
        restaurants = Gateway::Api.new(Ewa::App.config).all_rest
        restaurants.success? ? Success(restaurants.payload) : Failure(restaurants.message)
      rescue StandardError
          Failure('無法獲取資料 Cannot access db')
      end

      #binding.irb
      def reify_rest(restaurants_json)
        Representer::Restaurants.new(restaurants_json)
        .from_json
        .then { |rest_all| Success(rest_all) }
      rescue StandardError
=begin
        Representer::Restaurants.new(restaurants_json)
        .from_json
        .then { |rest_all| Success(rest_all) }
        binding.irb
=end
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
