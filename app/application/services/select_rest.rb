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

      def filter_data(input)
        result = Gateway::Api.new(Ewa::App.config).select_rest(input['town'], input['min_money'], input['max_money'], input['random'])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue ArgumentError
        Failure('參數錯誤 Invalid input')
      rescue StandardError
        Failure('無此資料 resource not found')
      end

      def reify_rest(rest_json)
        Representer::Restaurants.new(OpenStruct.new)
                                .from_json(rest_json)
                                .then { |rest_all| Success(rest_all['rests_infos']) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
