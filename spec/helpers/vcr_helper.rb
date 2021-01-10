# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'apis'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
    end
  end

  def self.configure_vcr_for_restaurant
    VCR.configure do |c|
      c.filter_sensitive_data('<GMAP_TOKEN>') { GMAP_TOKEN }
      c.filter_sensitive_data('<GMAP_TOKEN_ESC>') { CGI.escape(GMAP_TOKEN) }
      c.filter_sensitive_data('<CX>') { CX }
      c.filter_sensitive_data('<CX_ESC>') { CGI.escape(CX) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
