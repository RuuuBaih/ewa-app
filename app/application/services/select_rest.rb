# frozen_string_literal: true

require 'dry/transaction'
# require 'dry/monads/result'

module Ewa
  module Service
    # filter restaurants based on money
    class SelectRests
      # include Dry::Monads::Result::Mixin
      include Dry::Transaction
      def call(town, min_money, max_money)
        town = params['town']
        min_money = params['min_money']
        max_money = params['max_money']
        selected_entities = Gateway::Api.new(CodePraise::App.config).select_rest(town, min_money, max_money)

      rescue ArgumentError
        Failure('參數錯誤 Invalid input')

      rescue StandardError
        Failure('無此資料 resource not found')
      end
    end
  end
end
