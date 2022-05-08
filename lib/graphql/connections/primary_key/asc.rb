# frozen_string_literal: true

module GraphQL
  module Connections
    # Implements pagination by one field with asc order
    module PrimaryKey
      class Asc < Base
        private

        def page_comparable_method(query_type:, page_type:)
          if page_type == :previous
            return query_type == :query ? :lt : :lteq
          end

          query_type == :query ? :gt : :gteq
        end

        def first_limited_sorted_table
          arel_table[primary_key].asc
        end

        def last_limited_sorted_table
          arel_table[primary_key].desc
        end

        def sliced_comparable_method(type)
          type == :after ? :gt : :lt
        end
      end
    end
  end
end
