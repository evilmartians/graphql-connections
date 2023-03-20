# frozen_string_literal: true

module GraphQL
  module Connections
    module PrimaryKey
      # Base class for PrimaryKey pagination implementations
      class Base < ::GraphQL::Connections::Base
        COMPARABLE_METHODS = %i[
          gt lt lteq gteq
        ].freeze

        def initialize(*args, primary_key: nil, **kwargs)
          @primary_key = primary_key

          super(*args, **kwargs)
        end

        def has_previous_page
          return false if nodes.empty?
          
          if last
            items_exist?(type: :query, search: nodes.first[primary_key], page_type: :previous)
          elsif after
            items_exist?(type: :cursor, search: after_cursor, page_type: :previous)
          else
            false
          end
        end

        def has_next_page
          return false if nodes.empty?

          if first
            items_exist?(type: :query, search: nodes.last[primary_key], page_type: :next)
          elsif before
            items_exist?(type: :cursor, search: before_cursor, page_type: :next)
          else
            false
          end
        end

        def cursor_for(item)
          cursor = serialize(item[primary_key])
          cursor = encode(cursor) if opaque_cursor
          cursor
        end

        private

        def page_comparable_method(query_type:, page_type:)
          self.class::PAGE_COMPARABLE_METHODS.fetch(page_type).fetch(query_type)
        end

        def items_exist?(type:, search:, page_type:)
          comparable_method = page_comparable_method(query_type: type, page_type: page_type)

          if COMPARABLE_METHODS.exclude?(comparable_method)
            raise ArgumentError.new("Unknown #{comparable_method} comparable type. Allowed #{COMPARABLE_METHODS.join(", ")}")
          end

          items.where(arel_table[primary_key].send(comparable_method, search)).exists?
        end

        def limited_relation
          scope = sliced_relation
          nodes = []

          if first
            nodes |=
              scope
                .reorder(first_limited_sorted_table)
                .limit(first)
                .to_a
          end

          if last
            nodes |=
              scope
                .reorder(last_limited_sorted_table)
                .limit(last)
                .to_a.reverse!
          end

          nodes
        end

        def sliced_relation
          items
            .yield_self { |s| after ? sliced_items(items: s, cursor: after_cursor, type: :after) : s }
            .yield_self { |s| before ? sliced_items(items: s, cursor: before_cursor, type: :before) : s }
        end

        def sliced_items(items:, cursor:, type:)
          items.where(arel_table[primary_key].send(sliced_comparable_method(type), cursor))
        end

        def sliced_comparable_method(type)
          self.class::SLICED_COMPARABLE_METHODS.fetch(type.to_sym)
        end

        def first_limited_sorted_table
          raise NotImplementedError.new("method \"#{__method__}\" should be implemented in #{self.class.name} class")
        end

        def last_limited_sorted_table
          raise NotImplementedError.new("method \"#{__method__}\" should be implemented in #{self.class.name} class")
        end
      end
    end
  end
end
