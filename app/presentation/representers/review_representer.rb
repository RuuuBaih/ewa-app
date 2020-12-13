# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Ewa
  module Representer
    # Represents one review of one specific restaurant
    class Review < Roar::Decorator
      include Roar::JSON

      property :id
      property :author_name
      property :profile_photo_url
      property :relative_time_description
      property :text
      property :rating
    end
  end
end
