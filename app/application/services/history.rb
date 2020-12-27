# frozen_string_literal: true

require 'dry/transaction'

module Ewa
  module Service
    # Retrieves restaurant entity by searching restaurant name
    class History
      include Dry::Transaction

      step :history
      step :reify_rest

      private

      def history(history_records)
        history = history_records.map do |history_id|
          Gateway::Api.new(Ewa::App.config).pick_id(history_id)
        end
        history.success? ? Success(history.payload) : Failure(history.message)
      rescue StandardError
        Failure('資料錯誤 Database error!')
      end

      def reify_rest(hist_json)
        Representer::PickRestaurant.new(OpenStruct.new)
        .from_json(hist_json)
        .then { |history| Success(history['pick_rest']) }
      rescue StandardError
        Failure('無此資料 resource not found -- please try again')
      end
    end
  end
end