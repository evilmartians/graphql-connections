# frozen_string_literal: true

module GraphQL
  module Connections
    # Implements pagination by one field with desc order
    module PrimaryKey
      class Desc < Base
        private

        def page_comparable_method(query_type:, page_type:)
          if page_type == :previous
            return query_type == :query ? :gt : :gteq
          end

          query_type == :query ? :lt : :lteq
        end

        def first_limited_sorted_table
          arel_table[primary_key].desc
        end

        def last_limited_sorted_table
          arel_table[primary_key].asc
        end

        def sliced_comparable_method(type)
          type == :after ? :lt : :gt
        end
      end
    end
  end
end
