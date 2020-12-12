# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'restaurant_details_representer'

module Ewa
  module Representer
    # Represents searched restaurants infos
    class SearchedRestaurants < Roar::Decorator
      include Roar::JSON

      # returns searched rests details by restaurant name 
      collection :searched_rests, extend: Representer::RestaurantDetails
    end
  end
end
