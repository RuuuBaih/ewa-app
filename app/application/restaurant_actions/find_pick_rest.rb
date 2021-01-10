# frozen_string_literal: true

require 'dry/transaction'

module Ewa
  module RestaurantActions
    # filter restaurants based on money
    class FindRest
      include Dry::Transaction
      def call(rest_id)
        rest_detail = Repository::For.klass(Entity::Restaurant).find_by_rest_id(rest_id)
        Success(rest_detail)
      rescue StandardError
        Failure('資料錯誤 Data error!')
      end
    end
  end
end
