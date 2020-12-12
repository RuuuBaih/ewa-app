# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'picture_representer'

module Ewa
  module Representer
    # Represents searched restaurants' ids & names
    class RestaurantIdNamePic < Roar::Decorator
      include Roar::JSON

      property :id
      property :name
      collection :pictures, extend: Representer::Picture, class: OpenStruct

    end
  end
end
