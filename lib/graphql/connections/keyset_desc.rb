# frozen_string_literal: true

module GraphQL
  module Connections
    class KeysetDesc < ::GraphQL::Connections::Stable
      attr_reader :field_key

      def initialize(*args, field_key: nil, **kwargs)
        @field_key = field_key

        super(*args, **kwargs)
      end

      # rubocop:disable Naming/PredicateName, Metrics/AbcSize, Metrics/MethodLength
      def has_previous_page
        if last
          nodes.any? &&
            items.where(arel_table[field_key].eq(nodes.first[field_key]))
              .where(arel_table[primary_key].gt(nodes.first[primary_key]))
              .or(items.where(arel_table[field_key].gt(nodes.first[field_key])))
              .exists?
        elsif after
          items
            .where(arel_table[field_key].gt(after_cursor_date))
            .or(
              items.where(arel_table[field_key].eq(after_cursor_date))
                .where(arel_table[primary_key].gt(after_cursor_primary_key)),
            ).exists?
        else
          false
        end
      end

      def has_next_page
        if first
          nodes.any? &&
            items.where(arel_table[field_key].eq(nodes.last[field_key]))
              .where(arel_table[primary_key].lt(nodes.last[primary_key]))
              .or(items.where(arel_table[field_key].lt(nodes.last[field_key])))
              .exists?
        elsif before
          items
            .where(arel_table[field_key].lt(before_cursor_date))
            .or(
              items.where(arel_table[field_key].eq(before_cursor_date))
                .where(arel_table[primary_key].lt(before_cursor_primary_key)),
            ).exists?
        else
          false
        end
      end
      # rubocop:enable Naming/PredicateName, Metrics/AbcSize, Metrics/MethodLength

      SEPARATOR = '/'

      def cursor_for(item)
        cursor = [item[field_key], item[primary_key]].map { |value| serialize(value) }.join(SEPARATOR)
        cursor = encode(cursor) if opaque_cursor
        cursor
      end

      private

      def limited_relation # rubocop:disable Metrics/AbcSize
        scope = sliced_relation
        nodes = []

        if first
          nodes |=
            scope.reorder(arel_table[field_key].desc, arel_table[primary_key].desc)
              .limit(first).to_a
        end

        if last
          nodes |=
            scope.reorder(arel_table[field_key].asc, arel_table[primary_key].asc)
              .limit(last).to_a.reverse!
        end

        nodes
      end

      def sliced_relation
        items
          .yield_self { |s| after ? sliced_relation_after(s) : s }
          .yield_self { |s| before ? sliced_relation_before(s) : s }
      end

      def sliced_relation_after(relation)
        relation
          .where(arel_table[field_key].eq(after_cursor_date))
          .where(arel_table[primary_key].lt(after_cursor_primary_key))
          .or(relation.where(arel_table[field_key].lt(after_cursor_date)))
      end

      def sliced_relation_before(relation)
        relation
          .where(arel_table[field_key].eq(before_cursor_date))
          .where(arel_table[primary_key].gt(before_cursor_primary_key))
          .or(relation.where(arel_table[field_key].gt(before_cursor_date)))
      end

      def after_cursor_date
        @after_cursor_date ||= after_cursor.first
      end

      def after_cursor_primary_key
        @after_cursor_primary_key ||= after_cursor.last
      end

      def after_cursor
        @after_cursor ||= super.split(SEPARATOR)
      end

      def before_cursor_date
        @before_cursor_date ||= before_cursor.first
      end

      def before_cursor_primary_key
        @before_cursor_primary_key ||= before_cursor.last
      end

      def before_cursor
        @before_cursor ||= super.split(SEPARATOR)
      end
    end
  end
end
