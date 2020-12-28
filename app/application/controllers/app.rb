# frozen_string_literal: true

require 'json'
require 'roda'
require 'slim'
require 'slim/include'

module Ewa
  # Web App
  class App < Roda
    #include RouteHelpers
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :caching

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      # POST /
      routing.root do
        #binding.irb
        # Get cookie viewer's previously seen projects
        session[:watching] ||= []

        rest_all = Service::ShowAllRests.new.call
        if rest_all.failure?
          flash[:error] = rest_all.failure
          viewable_restaurants = []
          #routing.redirect '/'
        else
          restaurants = rest_all.value!
          viewable_restaurants = Views::Restaurant.new(restaurants)
        end

        #viewable_restaurants = Views::Restaurant.new(restaurants)

        if session[:watching].count > 5
          session[:watching] = session[:watching][0..4]
        end

        history = Service::History.new.call(session[:watching])
        #binding.irb
        if history.failure?
          flash[:error] = history.failure
          if session[:watching].empty?
            flash.now[:notice] = '尋找城市，開啟饗宴！ Search a place to get started!'
            #routing.redirect '/'
          end
          viewable_history = []
          #routing.redirect '/'
        else
          history_detail = history.value!
          binding.irb
          viewable_history = Views::History.new(history_detail)
        end
        #binding.irb
        #viewable_history = Views::History.new(history_detail)
        view 'home_test', locals: { restaurants: viewable_restaurants, history: viewable_history }
      end

      routing.on 'restaurant' do
        routing.is do
          # POST /restaurant
          routing.post do
            # parameters call from view
            filter_item = {}
            filter_item["town"] = routing.params['town']
            filter_item["min_money"] = routing.params['min_money']
            filter_item["max_money"] = routing.params['max_money']

            if (filter_item["min_money"].to_i >= filter_item["max_money"].to_i) ||
                  (filter_item["min_money"].to_i < 0) || (filter_item["max_money"].to_i <= 0)
              flash[:error] = '輸入格式錯誤 Wrong number type.'
              routing.redirect '/'
            end
            if (filter_item["max_money"].to_i <= 100)
              flash[:error] = '金額過小 Max price is too small.'
              routing.redirect '/'
            end
            # select restaurants from the database
            selected_rest = Service::SelectRests.new.call(filter_item)
            if selected_rest.failure?
              flash[:error] = selected_rest.failure
              routing.redirect '/'
            else
              rests_info = selected_rest.value!
            end
            #binding.irb
            if rests_info.length < 9
              flash[:error] = '資料過少，無法顯示 Not enough data.'
              response.status = 400
              routing.redirect '/'
            end
            viewable_restaurants = Views::Restaurant.new(rests_info)
            view 'restaurant', locals: { pick_9rests: viewable_restaurants }
          end
        end

        routing.on 'pick' do
          # POST /restaurant/pick
          # select one of 9 pick or search restaurant by name
          routing.is do
            routing.post do
              rest_id = routing.params['img_num'].to_i
              search = routing.params['search']
              search_result = Service::SearchRestName.new.call(search)
              #binding.irb

              if !rest_id.zero?
                rest_pick_id = rest_id
                routing.redirect "pick/#{rest_pick_id}"
                # viewable_projects = []
              elsif search_result.failure?
                flash[:error] = search_result.failure
                routing.redirect '/'
              else
                rest_search = search_result.value![0].id
                routing.redirect "pick/#{rest_search}"
              end
            end
          end

          routing.on String do |rest_id|
            routing.get do
              rest_find = Service::FindPickRest.new.call(rest_id)
              if rest_find.failure?
                flash[:error] = rest_find.failure
                routing.redirect '/'
              else
                rest_detail = rest_find.value!
              end
              session[:watching].insert(0, rest_detail.id).uniq!
              viewable_resdetail = Views::Resdetail.new(rest_detail)
              view 'res_detail', locals: { rest_detail: viewable_resdetail }
            end
          end
        end
      end
    end
  end
end
