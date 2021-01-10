# frozen_string_literal: true

require 'dry/transaction'

module Ewa
  module RestaurantActions
    # filter restaurants based on money
    class SelectRest
      include Dry::Transaction
      def call(town, min_money, max_money)
        selected_entities = Repository::For.klass(Entity::Restaurant)
                                           .find_by_town_money(town, min_money, max_money)
        Success(selected_entities)
      rescue StandardError
        Failure('篩選資料錯誤 Filter error!')
      end
    end

    # generate 9 restaurants
    class Pick_9
      include Dry::Transaction
      def call(selected_entities)
        rests = Restaurant::RestaurantOptionsMapper.new(selected_entities)
        pick_9rests = rests.random_9picks
        rests_info = Restaurant::RestaurantOptionsMapper::GetRestInfo.new(pick_9rests)
        Success(rests_info)
      rescue StandardError
        Failure('篩選資料錯誤 Filter error!')
      end
    end
  end
end
