# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'picture_representer'

module Ewa
  module Representer
    # Represents searched restaurants' ids & names
    class RestaurantIdNamePic < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :name
      collection :cover_pictures, extend: Representer::CoverPicture, class: OpenStruct

      link :search_by_id do
        "#{App.config.API_HOST}/api/v1/restaurants/picks/#{id}"
      end

      link :search_by_name do
        "#{App.config.API_HOST}/api/v1/restaurants/searches?name=#{name}"
      end

      def id
        represented.id
      end

      def name
        represented.name
      end
    end
  end
end
