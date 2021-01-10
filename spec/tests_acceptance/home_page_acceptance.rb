# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/home_page'

RESTAURANT = 'restaurant'

describe 'Homepage Acceptance Tests' do
  include PageObject::PageFactory

  before do
    @headless = Headless.new
    @browser = Watir::Browser.new :firefox, headless: true
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Visit Home page' do
    it '(HAPPY) should show searching bars' do
      # GIVEN: user is on the home page
      # WHEN: they visit the home page
      visit HomePage do |page|
        # THEN: user should see a searching bar
        _(page.town_select_list_element.present?).must_equal true
        _(page.min_money_element.present?).must_equal true
        _(page.max_money_element.present?).must_equal true
        _(page.filter_search_element.present?).must_equal true

        # THEN: if they visit on the first time, they should see a welcome message
        _(page.success_message.downcase).must_include 'start' if page.success_message_element.present?
      end
    end

    it '(HAPPY) should be able to search for town and money related restaurant for the first time' do
      # GIVEN: user is on the page with top 9 restaurants
      visit HomePage do |page|
        # WHEN: they enter the correct town & money format
        good_town = '中山區'
        good_min_mon = 10
        good_max_mon = 1000
        page.search_filtered_restaurants(good_town, good_min_mon, good_max_mon)

        # THEN: they should find themselves on the recommended restaurant's page
        @browser.url.include? RESTAURANT
      end
    end

    it '(BAD) should not be able to search an invalid money input (min_money > max_money)' do
      # GIVEN: user is on the page with top 9 restaurants
      visit HomePage do |page|
        # WHEN: they enter the correct town but invalid money format
        good_town = '中山區'
        bad_min_mon = 1000
        bad_max_mon = 100
        page.search_filtered_restaurants(good_town, bad_min_mon, bad_max_mon)

        # THEN: they should see a warning message
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message.downcase).must_include 'wrong number'
      end
    end

    it '(SAD) should not be able to search max number <= 100' do
      # GIVEN: user is on the page with top 9 restaurants
      visit HomePage do |page|
        # WHEN: they enter the correct town but too small max_money
        good_town = '中山區'
        good_min_mon = 0
        bad_max_mon = 100
        page.search_filtered_restaurants(good_town, good_min_mon, bad_max_mon)

        # THEN: they should see a warning message
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message.downcase).must_include 'max price is too small'
      end
    end

    it '(SAD) should show warning message if there are too few restaurants to show' do
      # GIVEN: user is on the page with top 9 restaurants
      visit HomePage do |page|
        # WHEN: they enter the correct town but too small max_money for restaurants data
        good_town = '中山區'
        min_mon = 0
        max_mon = 110
        page.search_filtered_restaurants(good_town, min_mon, max_mon)

        # THEN: they should see a warning message
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message.downcase).must_include 'not enough data'
      end
    end
  end
end
