# frozen_string_literal: true

module GraphQL
  module Connections
    # Implements pagination by one field with asc order
    module PrimaryKey
      class Asc < Base
        PAGE_COMPARABLE_METHODS = {
          previous: {query: :lt, cursor: :lteq},
          next: {query: :gt, cursor: :gteq}
        }

        SLICED_COMPARABLE_METHODS = {
          after: :gt,
          before: :lt
        }.freeze

        private

        def first_limited_sorted_table
          arel_table[primary_key].asc
        end

        def last_limited_sorted_table
          arel_table[primary_key].desc
        end
      end
    end
  end
end
