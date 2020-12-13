# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'picture_representer'
require_relative 'review_representer'
require_relative 'article_representer'
require_relative 'ewa_tag_representer'

module Ewa
  module Representer
    # Represents searched restaurants' details
    class RestaurantDetails < Roar::Decorator
      include Roar::JSON

      # consider the params after api restaurant_details?name&town
      property :id
      property :name
      property :branch_store_name
      property :town
      property :money
      property :city
      property :telephone
      property :cover_img
      property :tags
      property :pixnet_rating
      property :google_rating
      property :open_hours
      property :address
      property :website

      ## reviews & pictures maybe more than one (consider the usage)
      collection :reviews, extend: Representer::Review, class: OpenStruct
      collection :pictures, extend: Representer::Picture, class: OpenStruct

      property :article, extend: Representer::Article, class: OpenStruct
      property :ewa_tag, extend: Representer::EwaTag, class: OpenStruct
    end
  end
end
