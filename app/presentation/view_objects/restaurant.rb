# frozen_string_literal: true

module Views
    # View for a single project entity
  class Restaurant
    def initialize(restaurant)
      @restaurant = restaurant
    end

    def id
      @restaurant.map(&:id)
    end

    def name
      @restaurant.map(&:name)
    end

    def pic_link
      @restaurant.map { |rest| rest.cover_pictures.sample(1) }
    end
  end
end