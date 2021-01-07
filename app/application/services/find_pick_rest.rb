# frozen_string_literal: true

#require 'dry/monads/result'
require 'dry/transaction'
require 'json'

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
        if rest_detail.nil?
          raise StandardError
        end

        parsed_resp = JSON.parse(rest_detail.payload)
        status = parsed_resp['status']
        message = parsed_resp['message']

        if status == "processing"
          raise RuntimeError
        end
        rest_detail.success? ? Success(rest_detail.payload) : Failure(message)
      
      rescue RuntimeError
        Failure(message)
      rescue StandardError
        Failure('資料錯誤 Data error!')
      end

      def reify_rest(pick_json)
        Representer::PickRestaurant.new(OpenStruct.new)
        .from_json(pick_json)
        .then { |rest_pick|  Success(rest_pick['pick_rest']) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
