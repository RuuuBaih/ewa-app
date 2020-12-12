# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'
require_relative '../app/domain/restaurants/repositories/init'
require_relative '../app/domain/restaurants/entities/init'
require 'headless'
require 'watir'
require 'uri'
include Ewa
include Restaurant
include Repository
include Entity

RESTAURANT = 'restaurant'
PICK = 'pick'

describe 'Acceptance Tests' do
  before do
    @headless = Headless.new
    @browser = Watir::Browser.new :firefox, headless: true
    @homepage = 'http://localhost:9292/'
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Homepage' do
    describe 'Visit Home page' do
      it '(HAPPY) should show searching bars' do
        # GIVEN: user is on the home page without any projects
        @browser.goto @homepage

        # THEN: user should see basic headers, and a welcome message
        _(@browser.select_list(name: 'town').present?).must_equal true
        _(@browser.text_field(id: 'min_money').present?).must_equal true
        _(@browser.text_field(id: 'max_money').present?).must_equal true
        _(@browser.button(id: 'filter-form-submit').present?).must_equal true
      end
    end

    describe 'Search' do
      it '(HAPPY) should be able to search for town and money related restaurant for the first time' do
        # GIVEN: user is on the page with top 9 restaurants for the first visit
        @browser.goto @homepage

        # WHEN: they enter the correct town & money format
        good_town = '中山區'
        good_min_mon = 10
        good_max_mon = 1000
        @browser.select_list(name: 'town').options.each do |option|
          if option.text == good_town
            option.click
          end
        end
        @browser.text_field(id: 'min_money').set(good_min_mon)
        @browser.text_field(id: 'max_money').set(good_max_mon)
        @browser.button(id: 'filter-form-submit').click

        # THEN: they should find themselves on the recommended restaurant's page
        @browser.url.include? RESTAURANT
        if @browser.div(id: 'flash_bar_success').present?
          _(@browser.div(id: 'flash_bar_success').text.downcase).must_include 'start'
        end
      end

      it '(BAD) should not be able to search an invalid money input ' do
        # GIVEN: user is on the home page
        @browser.goto @homepage

        # WHEN: they request restaurants with an invalid town input
        good_town = '中山區'
        bad_min_mon = 1000
        bad_max_mon = 100
        @browser.select_list(name: 'town').options.each do |option|
          if option.text == good_town
            option.click
          end
        end
        @browser.text_field(id: 'min_money').set(bad_min_mon)
        @browser.text_field(id: 'max_money').set(bad_max_mon)
        @browser.button(id: 'filter-form-submit').click

        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'wrong number'
      end
    end
  end

  describe 'Recommended Restaurant Page' do
    good_town = '中山區'
    good_min_mon = 10
    good_max_mon = 1000

    describe '9 recommended restaurants' do
      it '(HAPPY) should see 9 recommended restaurants' do
        # GIVEN: user is on the homepage's searching bars
        @browser.goto @homepage
        @browser.select_list(name: 'town').options.each do |option|
          if option.text == good_town
            option.click
          end
        end
        @browser.text_field(id: 'min_money').set(good_min_mon)
        @browser.text_field(id: 'max_money').set(good_max_mon)

        # WHEN: they enter the correct town & money format and goes directly to the restaurants recommended page
        @browser.button(id: 'filter-form-submit').click

        # THEN: they should see the 9 restaurants recommended
        9.times do |num|
          _(@browser.button(id: "rest_pick_#{num}").present?).must_equal true
        end
      end
    end

    describe 'Searching bar & Retry button' do
      it '(HAPPY) should see the try again button and also the search bars' do
        # GIVEN: user is on the homepage's searching bars
        @browser.goto @homepage
        @browser.select_list(name: 'town').options.each do |option|
          if option.text == good_town
            option.click
          end
        end
        @browser.text_field(id: 'min_money').set(good_min_mon)
        @browser.text_field(id: 'max_money').set(good_max_mon)

        # WHEN: they enter the correct town & money format and goes directly to the restaurants recommended page
        @browser.button(id: 'filter-form-submit').click

        # THEN: they should see the searching bars and refresh button on the restaurant recommended page
        _(@browser.select_list(name: 'town').present?).must_equal true
        _(@browser.text_field(id: 'min_money').present?).must_equal true
        _(@browser.text_field(id: 'max_money').present?).must_equal true
        _(@browser.button(id: 'refresh-button').present?).must_equal true
      end
    end
  end

  describe 'Restaurant Pick Page' do
    good_town = '中山區'
    good_min_mon = 10
    good_max_mon = 1000
    it '(HAPPY) should show restaurant details when users click on recommend restaurant image button' do
      # GIVEN: user is on the recommended restaurants' page
      flag = true
      while flag
        @browser.goto @homepage
        @browser.select_list(name: 'town').options.each do |option|
          if option.text == good_town
            option.click
          end
        end
        @browser.text_field(id: 'min_money').set(good_min_mon)
        @browser.text_field(id: 'max_money').set(good_max_mon)
        @browser.button(id: 'filter-form-submit').click

        # WHEN user clicks on the restaurant image button
        @browser.button(id: 'rest_pick_1').click

        # THEN: user should see the related restaurant details that they've clicked
        uri = URI(@browser.url)
        uri_path = uri.path
        rest_id = uri_path.split('/').last.to_i
        rest_details = Repository::For.klass(Entity::Restaurant).find_by_rest_id(rest_id)

        flag = false if rest_details
      end

      ## table info
      rest_info_tab = @browser.table(id: 'rest_infos')
      ### col names
      names_arr = %w[Tel Address Cost Rating]
      text_arr = [rest_details.telephone, rest_details.address, rest_details.money, rest_details.google_rating]
      rest_info_tab.trs.each_with_index.select do |col, i|
        content = col.text
        content.include? names_arr[i]
        content.include? text_arr[i].to_s
      end

      ## gmap iframe
      _(@browser.iframe(id: 'gmap_iframe').present?).must_equal true

      ## blog article
      _(@browser.iframe(id: 'blog_article').present?).must_equal true
      src_link = @browser.iframe(id: 'blog_article').src
      if src_link != 'https://i.imgur/com/kfi33rq.png'
        _(@browser.iframe(id: 'blog_article').src).must_equal rest_details.article.link
      end

      ## photos
      9.times do |num|
        _(@browser.img(id: "picture_#{num}").present?).must_equal true
      end

      ## reviews
      5.times do |num|
        _(@browser.div(id: "review_#{num}").present?).must_equal true
        _(@browser.div(id: "review_#{num}").img.present?).must_equal true
        _(@browser.div(id: "review_#{num}").span(id: "review_name_#{num}").present?).must_equal true
        _(@browser.div(id: "review_#{num}").span(id: "review_text_#{num}").present?).must_equal true
        _(@browser.div(id: "review_#{num}").div(id: "review_time_#{num}").present?).must_equal true
      end
    end
  end
end
