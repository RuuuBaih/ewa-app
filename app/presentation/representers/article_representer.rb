# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Ewa
  module Representer
    # Represents article of one specific restaurants
    class Article < Roar::Decorator
      include Roar::JSON
      property :id
      property :restaurant_name
      property :link
    end
  end
end
