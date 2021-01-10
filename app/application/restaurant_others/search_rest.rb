# frozen_string_literal: true

# require 'dry/monads'
require 'dry/transaction'

module Ewa
  module RestaurantOthers
    # Retrieves restaurant entity by searching restaurant name
    class SearchRest
      include Dry::Transaction
      # include Dry::Monads::Result::Mixin

      def call(search)
        rest_pick_id = Repository::For.klass(Entity::Restaurant).rest_convert2_id(search).id
        Success(rest_pick_id)
      rescue StandardError
        Failure('無此餐廳 Restaurant is not found.')
      end
    end
  end
end
