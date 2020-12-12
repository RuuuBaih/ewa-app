# frozen_string_literal: true

require_relative 'spec_helper'

REST_NAME = '螺絲瑪莉 Rose Mary'
KEYWORDS_ERR_TEST = 'soumyaray'
POI_LENGTH = 1
REVIEW_LENGTH = 5

describe 'Tests Ewa API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GMAP_TOKEN>') { GMAP_TOKEN }
    c.filter_sensitive_data('<GMAP_TOKEN_ESC>') { CGI.escape(GMAP_TOKEN) }
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
    describe 'poi' do
      it 'HAPPY: should have same length of poi' do
        poi = Ewa::Restaurant::RestaurantMapper.new(GMAP_TOKEN).poi_details
        _(poi.length).must_equal POI_LENGTH
      end
    end
    #     describe 'article' do
    #       it 'HAPPY: should have same length of poi' do
    #         _(Ewa::Pixnet::PoiApi.new(1, 10).poi_lists.values[2].values[4].length).must_equal POI_LENGTH
    #       end
    #     end
  end

  describe 'Tests Google API library' do
    describe 'Google place api' do
      it 'Happy: should have correct google place attribute' do
        restaurant = Ewa::Restaurant::RestaurantMapper.new(GMAP_TOKEN).restaurant_obj_lists
        _(restaurant[0]['reviews'].length).must_equal REVIEW_LENGTH
        _(restaurant[0]['name']).must_equal REST_NAME
      end

      it 'BAD: should raise exception when unauthorized' do
        _(proc do
          Ewa::Restaurant::RestaurantMapper.new('BAD_TOKEN').restaurant_obj_lists
        end).must_raise Ewa::Gmap::PlaceApi::Response::Unauthorized
      end
    end
  end
end
