# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Ewa
  module Representer
    # Represents one of a picture of one specific restaurant
    class Picture < Roar::Decorator
      include Roar::JSON

      property :id
      property :link
    end
  end
end
