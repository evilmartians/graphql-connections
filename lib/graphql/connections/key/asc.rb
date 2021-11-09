# frozen_string_literal: true

module GraphQL
  module Connections
    module Key
      # Implements pagination by one field with asc order
      class Asc < ::GraphQL::Connections::Key::Base
        def has_previous_page
          previous_items_exist?
        end

        def has_next_page
          next_items_exist?
        end

        private

        def first_item
          nodes.first
        end

        def last_item
          nodes.last
        end

        def limited_relation
          nodes = []

          nodes |= apply_limit(first, :asc)
          nodes |= apply_limit(last, :desc).reverse!

          nodes
        end
      end
    end
  end
end
