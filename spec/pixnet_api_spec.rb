# frozen_string_literal: false

#require 'simplecov'
#SimpleCov.start
require_relative 'spec_helper'
require 'minitest/autorun'
require 'minitest/rg'
require_relative '../lib/pixnet_lib/keywords/pix_keyword_api'
require_relative '../lib/pixnet_lib/poi/pix_poi_api'

KEYWORDS_EN_TEST = 'Gucci'.freeze
KEYWORDS_CN_TEST = '螺絲瑪麗'.freeze
KEYWORDS_ERR_TEST = 'soumyaray'.freeze
POI_LENGTH = 10

describe 'Tests PIXNET API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette PIXNET_CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Tests PIXNET API library' do
    describe 'keywords' do
      it 'HAPPY: chinese keyword should return a list of keywords' do
        cn_keyword_lists = JustRuIt::PixKeywordApi.new(KEYWORDS_CN_TEST).keyword_lists
        _(0..20).must_include cn_keyword_lists.count
        # _(JustRuIt::PixKeywordApi.new(KEYWORDS_CN_TEST).keyword_lists.class).must_equal Array
      end

      it 'HAPPY: english keyword should return a list of keywords' do
        en_keyword_lists = JustRuIt::PixKeywordApi.new(KEYWORDS_CN_TEST).keyword_lists
        _(0..20).must_include en_keyword_lists.count
        # _(JustRuIt::PixKeywordApi.new(KEYWORDS_EN_TEST).keyword_lists.class).must_equal Array
      end

      it 'SAD: the keyword is not found' do
        err_keyword_lists = JustRuIt::PixKeywordApi.new(KEYWORDS_ERR_TEST).keyword_lists
        _(err_keyword_lists.count).must_equal 0
        # _(JustRuIt::PixKeywordApi.new(KEYWORDS_ERR_TEST).keyword_lists).must_equal []
      end
    end

    describe 'poi' do
      it 'HAPPY: should have same length of ' do
        _(JustRuIt::PixPoiApi.new(10).poi_lists.values[4].length).must_equal POI_LENGTH
      end
    end
  end
end
