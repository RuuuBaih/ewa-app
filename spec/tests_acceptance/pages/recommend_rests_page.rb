# frozen_string_literal: true

# Page object for Recommend Restaurant page
class RecommendRestaurantPage
  include PageObject


  page_url Ewa::App.config.APP_HOST

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')


  select_list(:town_select_list, name: 'town')
  text_field(:min_money, id: 'min_money')
  text_field(:max_money, id: 'max_money')
  button(:filter_search, id: 'filter-form-submit')
  button(:refresh_button, id: 'refresh-button')


  9.times do |num|
    button("rest_pick_#{num}".to_sym , id: "rest_pick_#{num}")
  end

  def search_filtered_restaurants(town, min_money, max_money)
    self.town_select_list_element.options.each do |option|
      if option.text == town
        option.click
      end
    end

    self.min_money = min_money
    self.max_money = max_money
    self.filter_search
  end
end

