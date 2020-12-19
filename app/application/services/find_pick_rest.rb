# frozen_string_literal: true

#require 'dry/monads/result'
require 'dry/transaction'

module Ewa
  module Service
    # find picked restaurants by restaurant id
    class FindPickRest
      include Dry::Transaction
      # include Dry::Monads::Result::Mixin
      step :pick_id
      step :reify_rest

      private

      def pick_id(rest_id)
        rest_detail = Gateway::Api.new(Ewa::App.config).pick_id(rest_id)
        rest_detail.success? ? Success(rest_detail.payload) : Failure(rest_detail.message)

        # if database results not found
        if rest_detail.nil?
          raise StandarError
        end        
      rescue StandardError
        Failure('資料錯誤 Data error!')
      end

      def reify_rest(pick_json)
        Representer::PickRestaurant.new(OpenStruct.new)
        .from_json(pick_json)
        .then { |project| Success(project) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
