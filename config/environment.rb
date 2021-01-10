# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'delegate'

module Ewa
  # Environment-specific configuration
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    use Rack::Session::Cookie, secret: config.SESSION_SECRET
  end
end
