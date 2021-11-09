# frozen_string_literal: true

module GraphQL
  module Connections
    module Key
      # Implements pagination by one field with desc order
      class Desc < ::GraphQL::Connections::Key::Base
        def initialize(*args, **kwargs)
          super(*args, **kwargs)

          @before_value, @after_value = @after_value, @before_value
          @first_value, @last_value = @last_value, @first_value
        end

        def first
          @first ||= limit_pagination_argument(@first_value, max_page_size)
        end

        def last
          @last ||= begin
            capped = limit_pagination_argument(@last_value, max_page_size)
            if capped.nil? && first.nil?
              capped = max_page_size
            end
            capped
          end
        end

        def has_previous_page
          next_items_exist?
        end

        def has_next_page
          previous_items_exist?
        end

        private

        def first_item
          nodes.last
        end

        def last_item
          nodes.first
        end

        def limited_relation
          nodes = []

          nodes |= apply_limit(last, :desc)
          nodes |= apply_limit(first, :asc).reverse!

          nodes
        end
      end
    end
  end
end
