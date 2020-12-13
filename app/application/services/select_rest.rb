# frozen_string_literal: true

# require 'dry/transaction'
require 'dry/monads/all'

module Ewa
  module Service
    # filter restaurants based on money
    class SelectRests
      # include Dry::Transaction
      include Dry::Monads::Result::Mixin
      def call(input)
        # input is a response obj
        params = input.call.value!
        town = params['town']
        min_money = params['min_money']
        max_money = params['max_money']
        # default page is 1 and records on per page is 5
        # which page
        page = params.key?("page") ? params["page"].to_i : 1 
        # how many records on per page  
        # 5 can be changed in the future
        per_page = params.key?("per_page") ? params["per_page"].to_i : 5
        if per_page > 10
          raise StandardError
        end

        # input invalid
        if (page == 0) or (per_page == 0)
          raise ArgumentError
        end

        selected_entities = Gateway::Api.new(CodePraise::App.config).select_rest(town, min_money, max_money)
        if selected_entities == []
          raise StandardError
        end

        total = selected_entities.count

        # slice restaurants(array of entities) into pieces
        limited_rests = selected_entities.each_slice(per_page).to_a[page - 1]

        Response::RestaurantsResp.new(total, limited_rests)
          .then do |filtered_rests|
          Success(Response::ApiResult.new(status: :ok, message: filtered_rests))
        end

      rescue ArgumentError
        Failure(Response::ApiResult.new(status: :cannot_process, message: '參數錯誤 Invalid input'))

      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: '無此資料 resource not found'))
      end
    end
  end
end
