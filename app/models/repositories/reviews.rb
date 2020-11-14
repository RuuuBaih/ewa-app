# frozen_string_literal: true

module Ewa
    module Repository
      # Repository for Reviews
      class Reviews
        def self.find_review_by_id(id)
          rebuild_entity Database::ReviewOrm.first(id: id)
        end
 
        def self.find_first_review_by_restaurant_id(restaurant_id)
          rebuild_entity Database::ReviewOrm.first(restaurant_id: restaurant_id)
        end

        def self.find_all_reviews_by_restaurant_id(restaurant_id)
          rebuild_many Database::ReviewOrm.where(restaurant_id: restaurant_id).all
        end

        def self.rebuild_entity(db_record)
          return nil unless db_record
  
          Entity::Review.new(
            id: db_record.id,
            restaurant_id: db_record.restaurant_id, 
            author_name: db_record.author_name,
            profile_photo_url: db_record.profile_photo_url,
            relative_time_description: db_record.relative_time_description,
            text: db_record.text
          )
        end

        def self.rebuild_many(db_records)
          db_records.map do |db_review|
            Reviews.rebuild_entity(db_review)
          end
        end
      end
    end
end