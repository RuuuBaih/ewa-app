# frozen_string_literal: true

require 'dry/transaction'

module Ewa
  module RestaurantActions
    # filter restaurants based on money
    class Rest
      include Dry::Transaction
      def RestAll
        restaurants = Repository::For.klass(Entity::Restaurant).all
        Success(restaurants)
      rescue StandardError
        Failure('資料錯誤 Data error!')
      end
    end
  end
end
