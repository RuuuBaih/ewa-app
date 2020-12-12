# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/recommend_rests_page'

RESTAURANT = 'restaurant'

describe 'RecommendRestaurantPage Acceptance Tests' do
  include PageObject::PageFactory

  before do
    @headless = Headless.new
    @browser = Watir::Browser.new :firefox, headless: true
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Recommended Restaurant Page' do
    good_town = '中山區'
    good_min_mon = 10
    good_max_mon = 1000

    describe '9 recommended restaurants' do
      it '(HAPPY) should see 9 recommended restaurants' do
        # GIVEN: user is on the homepage's searching bars
        visit RecommendRestaurantPage do |page|
          # WHEN: they enter the correct town & money format and goes directly to the restaurants recommended page
          page.search_filtered_restaurants(good_town, good_min_mon, good_max_mon)
          # THEN: they should see the 9 restaurants recommended
          _(page.rest_pick_0_element.present?).must_equal true
          _(page.rest_pick_1_element.present?).must_equal true
          _(page.rest_pick_2_element.present?).must_equal true
          _(page.rest_pick_3_element.present?).must_equal true
          _(page.rest_pick_4_element.present?).must_equal true
          _(page.rest_pick_5_element.present?).must_equal true
          _(page.rest_pick_6_element.present?).must_equal true
          _(page.rest_pick_7_element.present?).must_equal true
          _(page.rest_pick_8_element.present?).must_equal true
        end
      end
    end

    describe 'Searching bar & Retry button' do
      it '(HAPPY) should see the try again button and also the search bars' do
        # GIVEN: user is on the page with top 9 restaurants
        visit RecommendRestaurantPage do |page|
          # WHEN: they enter the correct town & money format and goes directly to the restaurants recommended page
          good_town = '中山區'
          good_min_mon = 10
          good_max_mon = 1000
          page.search_filtered_restaurants(good_town, good_min_mon, good_max_mon)

          # THEN: they should see the searching bars and refresh button on the restaurant recommended page
          @browser.url.include? RESTAURANT
          _(page.town_select_list_element.present?).must_equal true
          _(page.min_money_element.present?).must_equal true
          _(page.max_money_element.present?).must_equal true
          _(page.filter_search_element.present?).must_equal true
          _(page.refresh_button_element.present?).must_equal true
        end
      end
    end
  end
end
 
