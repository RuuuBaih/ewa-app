# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Ewa
  module Representer
    # Represents ewa_tag of one specific restaurant
    class EwaTag < Roar::Decorator
      include Roar::JSON
      property :id
      property :ewa_tag
    end
  end
end
