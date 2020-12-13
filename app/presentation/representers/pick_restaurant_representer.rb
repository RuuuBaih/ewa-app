# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'restaurant_details_representer'

module Ewa
  module Representer
    # Represents pick restaurant infos
    class PickRestaurant < Roar::Decorator
      include Roar::JSON

      # returns pick rest details 
      property :pick_rest, extend: Representer::RestaurantDetails
    end
  end
end
