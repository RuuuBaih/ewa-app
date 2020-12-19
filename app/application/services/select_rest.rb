# frozen_string_literal: true

require 'dry/transaction'
# require 'dry/monads/result'

module Ewa
  module Service
    # filter restaurants based on money
    class SelectRests
      # include Dry::Monads::Result::Mixin
      include Dry::Transaction

      step :filter_data
      step :reify_rest

      private

      def filter_data(town, min_money, max_money)
        town = params['town']
        min_money = params['min_money']
        max_money = params['max_money']
        result = Gateway::Api.new(Ewa::App.config).select_rest(town, min_money, max_money)

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue ArgumentError
        Failure('參數錯誤 Invalid input')
      rescue StandardError
        Failure('無此資料 resource not found')
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
