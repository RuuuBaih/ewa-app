# frozen_string_literal: true

require 'dry/monads/result'

module Ewa
  module Service
    # find picked restaurants by restaurant id
    class FindPickRest
      # include Dry::Transaction
      include Dry::Monads::Result::Mixin
      def call(rest_id)

        rest_detail = Gateway::Api.new(CodePraise::App.config).pick_id(rest_id)

        # if database results not found
        if rest_detail.nil?
          raise StandarError
        end        
      rescue StandardError
        Failure('資料錯誤 Data error!')
      end
    end
  end
end
