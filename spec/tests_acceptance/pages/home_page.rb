# frozen_string_literal: true

# Page object for home page
class HomePage
  include PageObject

  page_url Ewa::App.config.APP_HOST

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  select_list(:town_select_list, name: 'town')
  text_field(:min_money, id: 'min_money')
  text_field(:max_money, id: 'max_money')
  button(:filter_search, id: 'filter-form-submit')

  def search_filtered_restaurants(town, min_money, max_money)
    town_select_list_element.options.each do |option|
      option.click if option.text == town
    end

    self.min_money = min_money
    self.max_money = max_money
    filter_search
  end
end
