# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Ewa
  module Representer
    # Represents one of a cover picture of one specific restaurant
    class CoverPicture < Roar::Decorator
      include Roar::JSON

      property :id
      property :picture_link
      property :article_link
    end
  end
end
