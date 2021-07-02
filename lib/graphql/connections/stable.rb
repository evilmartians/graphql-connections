# frozen_string_literal: true

module GraphQL
  module Connections
    # Cursor-based pagination to work with `ActiveRecord::Relation`s.
    # Implements a mechanism for serving stable connections based on column values.
    # If objects are created or destroyed during pagination, the list of items won't be disrupted.
    #
    # Inspired by `GraphQL::Pro`s Stable Relation Connections
    # https://graphql-ruby.org/pagination/stable_relation_connections.html
    #
    # For more information see GraphQL Cursor Connections Specification
    # https://relay.dev/graphql/connections.htm
    class Stable < ::GraphQL::Connections::Base
      def initialize(*args, primary_key: nil, **kwargs)
        @primary_key = primary_key

        super(*args, **kwargs)
      end

      def has_previous_page # rubocop:disable Naming/PredicateName
        if last
          nodes.any? && items.where(arel_table[primary_key].lt(nodes.first[primary_key])).exists?
        elsif after
          items.where(arel_table[primary_key].lteq(after_cursor)).exists?
        else
          false
        end
      end

      def has_next_page # rubocop:disable Naming/PredicateName
        if first
          nodes.any? && items.where(arel_table[primary_key].gt(nodes.last[primary_key])).exists?
        elsif before
          items.where(arel_table[primary_key].gteq(before_cursor)).exists?
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

      def limited_relation
        scope = sliced_relation
        nodes = []

        if first
          nodes |= scope
            .reorder(arel_table[primary_key].asc)
            .limit(first)
            .to_a
        end

        if last
          nodes |= scope
            .reorder(arel_table[primary_key].desc)
            .limit(last)
            .to_a.reverse!
        end

        nodes
      end

      def sliced_relation
        items
          .yield_self { |s| after ? s.where(arel_table[primary_key].gt(after_cursor)) : s }
          .yield_self { |s| before ? s.where(arel_table[primary_key].lt(before_cursor)) : s }
      end
    end
  end
end
