# frozen_string_literal: true

module Views
    # View for a single project entity
  class Resdetail
    def initialize(resdetail)
      @resdetail = resdetail
    end

    def entity
      @resdetail
    end
  
    def ewa_tag
      @resdetail.ewa_tag.ewa_tag
    end

    def name
      @resdetail.name
    end

    def telephone
      @resdetail.telephone
    end

    def address
      @resdetail.address
    end

    def money
      @resdetail.money
    end

    def tags
      @resdetail.tags.join(" ")
    end

    def open_hours
      @resdetail.open_hours
    end

    def website
      @resdetail.website
    end

    def google_rating
      @resdetail.google_rating
    end

    def pic_link
      @resdetail.pictures.map(&:link)
    end

    def article_link
      article = []
      article << @resdetail.article.link
      @resdetail.cover_pictures.each_with_index do |_, num|
        article << @resdetail.cover_pictures[num].article_link
      end
      article.sample(1)[0]
    end

    def author_name
      @resdetail.reviews.map(&:author_name)
    end

    def profile_photo_url
      @resdetail.reviews.map(&:profile_photo_url)
    end

    def review_rating
      @resdetail.reviews.map(&:rating)
    end

    def review_relative_time_description
      @resdetail.reviews.map(&:relative_time_description)
    end

    def review_text
      @resdetail.reviews.map(&:text)
    end
    
    def branch_store_name
      @resdetail.branch_store_name
    end

    def town
      @resdetail.town
    end
  end
end