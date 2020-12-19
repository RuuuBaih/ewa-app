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
        restaurants.success? ? Success(restaurants.payload) : Failure(restaurants.message)

      rescue ArgumentError
          Failure('參數錯誤 Invalid input')
      rescue StandardError
          Failure('無法獲取資料 Cannot access db')
      end

      def reify_rest(rest_json)
        Representer::Restaurants.new(OpenStruct.new)
        .from_json(rest_json)
        .then { |project| Success(project) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
