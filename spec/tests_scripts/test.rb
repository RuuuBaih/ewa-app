# frozen_string_literal: true

require_relative 'helpers/spec_helper'
REST_NAME = '螺絲瑪莉 Rose Mary'
# @article_mapper = Ewa::Restaurant::ArticleMapper
#
# puts 'newest_article'
# puts @article_mapper.new(REST_NAME).the_newest_article
@restaurant_mapper = Ewa::Restaurant::RestaurantMapper
# # puts 'poi_details'
# poi = @restaurant_mapper.new(GMAP_TOKEN).PoiDetails.poi_details
# puts poi
# puts poi.length
# puts poi.class
# puts poi[0]['category_id']
#
# restaurant_entities = Ewa::Restaurant::RestaurantMapper.new(GMAP_TOKEN).restaurant_obj_lists[2]
# puts restaurant_entities

town = '三峽區'
min_money = 10
max_money = 1000
Ewa::Repository::For.klass(Entity::Restaurant).all
new_restaurant_entities = Ewa::Repository::For.klass(Entity::Restaurant).find_by_town_money(town, min_money, max_money)
pick_rests = Ewa::Mapper::RestaurantOptions.new(new_restaurant_entities)._9picks
puts pick_rests
pick_one = Ewa::Mapper::RestaurantOptions::PickOne.new(pick_rests, 2)
puts pick_one
