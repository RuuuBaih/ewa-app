# frozen_string_literal: true

# require 'dry/transaction'
require 'dry/monads/all'

module Ewa
  module Service
    # filter restaurants based on money
    class ShowAllRests
      # include Dry::Transaction
      include Dry::Monads::Result::Mixin

      def call
        restaurants = Gateway::Api.new(CodePraise::App.config).all_rest
      rescue ArgumentError
        Failure('參數錯誤 Invalid input'))
      rescue StandardError
        Failure('無法獲取資料 Cannot access db'))
      end
    end
  end
end
