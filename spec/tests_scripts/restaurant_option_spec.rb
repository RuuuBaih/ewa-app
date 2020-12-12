# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
# require_relative 'helpers/database_helper'

describe 'Test restaurant Mapper and Gateway' do
  #     VcrHelper.setup_vcr
  #     DatabaseHelper.setup_database_cleaner
  #
  #     before do
  #       VcrHelper.configure_vcr_for_github
  #       DatabaseHelper.wipe_database
  #     end
  describe 'Test Ewa_tag' do
    before do
      @ewa_tag = Ewa::Value::EwaTags
    end
    it 'HAPPY: should return correct tag' do
      _(@ewa_tag.new('薌筑園', 0, 4).ewa_tag_hash[:restaurant_id]).must_equal '薌筑園'
      _(@ewa_tag.new('薌筑園', 0, 4).ewa_tag_hash[:ewa_tag]).must_equal '查無價格 No price'
    end
  end
end
