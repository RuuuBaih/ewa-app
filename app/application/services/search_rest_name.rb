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
        rest_searches = Gateway::Api.new(CodePraise::App.config).search_name(search)
        # if database results not found
        if rest_searches == []
          raise StandardError
        end
        rest_searches.success? ? Success(rest_searches.payload) : Failure(rest_searches.message)

      rescue StandardError
        Failure('無此資料 Resource not found')
      end

      def reify_rest(search_json)
        Representer::SearchedRestaurants.new(OpenStruct.new)
        .from_json(search_json)
        .then { |project| Success(project) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end
