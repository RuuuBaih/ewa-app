# frozen_string_literal: true

module Views
    # View for a single project entity
    class History
      def initialize(history)
        @history = history
      end
      
      def entity
        @history
      end

      def name
        @history.name
      end

      def id
        @history.id
      end

    end
end