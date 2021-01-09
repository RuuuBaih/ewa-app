# frozen_string_literal: true

# require 'dry/monads/all'
require 'dry/transaction'

module Ewa
  module Service
    # Retrieves restaurant entity by searching restaurant name
    class SearchRestName
      include Dry::Transaction
      #include Dry::Monads::Result::Mixin
      step :search_name
      step :reify_rest

      private

      def search_name(search)
        rest_searches = Gateway::Api.new(Ewa::App.config).search_name(search)
        parsed_resp = JSON.parse(rest_searches.payload)
        message = parsed_resp['message']
        # if database results not found
        if rest_searches == []
          raise StandardError
        end
        rest_searches.success? ? Success(rest_searches.payload) : Failure(message)

      rescue StandardError
        Failure('無此資料 Resource not found')
      end

      def reify_rest(search_json)
        #binding.irb
        Representer::SearchedRestaurants.new(OpenStruct.new)
        .from_json(search_json)
        .then { |rest_search|  Success(rest_search['searched_rests']) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
