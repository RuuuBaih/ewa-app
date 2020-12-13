# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'restaurant_id_name_pic_representer'

module Ewa
  module Representer
    # Represents Restaurants with ids & names
    class Restaurants < Roar::Decorator
      include Roar::JSON

      # :rests_infos include a collection of [ restaurant id & restaurant name & pictures]
      property :total
      collection :rests_infos, extend: Representer::RestaurantIdNamePic
    

    end  
  end
end
