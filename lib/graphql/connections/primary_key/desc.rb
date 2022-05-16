# frozen_string_literal: true

module GraphQL
  module Connections
    # Implements pagination by one field with desc order
    module PrimaryKey
      class Desc < Base
        PAGE_COMPARABLE_METHODS = {
          previous: {query: :gt, cursor: :gteq},
          next: {query: :lt, cursor: :lteq}
        }.freeze

        SLICED_COMPARABLE_METHODS = {
          after: :lt,
          before: :gt
        }.freeze

        private

        def first_limited_sorted_table
          arel_table[primary_key].desc
        end

        def last_limited_sorted_table
          arel_table[primary_key].asc
        end
      end
    end
  end
end
