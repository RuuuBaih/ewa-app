# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require_relative '../../init'

USERNAME = ''
PROJECT_NAME = 'SOA_project'
GMAP_TOKEN = Ewa::App.config.GMAP_TOKEN

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'apis'

# Helper methods
def homepage
  Ewa::App.config.APP_HOST
end
