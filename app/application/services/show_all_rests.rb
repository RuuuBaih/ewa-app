# frozen_string_literal: true

# require 'dry/transaction'
require 'dry/monads/all'

module Ewa
  module Service
    # filter restaurants based on money
    class ShowAllRests
      # include Dry::Transaction
      include Dry::Monads::Result::Mixin

      def call(input)
        # default page is 1 and records on per page is 5
        page = input.key?('page') ? input['page'].to_i : 1
        per_page = input.key?('per_page') ? input['per_page'].to_i : 5

        # one page cannot access higher than 10 records (in the future can be more)
        if per_page > 10
          raise StandardError
        end

        # input invalid
        if (page == 0) or (per_page == 0)
          raise ArgumentError
        end

        restaurants = Gateway::Api.new(CodePraise::App.config).all_rest
        total = restaurants.count
       
        # slice restaurants(array of entities) into pieces
        limited_rests = restaurants.each_slice(per_page).to_a[page - 1]

        
        resp = Response::RestaurantsResp.new(total, limited_rests)
        #raise StandardError
          .then do |all_rests|
          Success(Response::ApiResult.new(status: :ok, message: all_rests))
        end

      rescue ArgumentError
        Failure(Response::ApiResult.new(status: :cannot_process, message: '參數錯誤 Invalid input'))

      rescue StandardError
        #raise "#{resp.inspect}"
        Failure(Response::ApiResult.new(status: :internal_error, message: '無法獲取資料 Cannot access db'))
      end
    end
  end
end
