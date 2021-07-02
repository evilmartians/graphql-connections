# frozen_string_literal: true

module GraphQL
  module Connections
    class Base < ::GraphQL::Pagination::Connection
      attr_reader :opaque_cursor

      delegate :arel_table, to: :items

      def initialize(*args, opaque_cursor: true, **kwargs)
        @opaque_cursor = opaque_cursor

        super(*args, **kwargs)
      end

      def primary_key
        @primary_key ||= items.model.primary_key
      end

      def nodes
        @nodes ||= limited_relation
      end

      def has_previous_page # rubocop:disable Naming/PredicateName
        raise NotImplementedError
      end

      def has_next_page # rubocop:disable Naming/PredicateName
        raise NotImplementedError
      end

      def cursor_for(item)
        raise NotImplementedError
      end

      private

      def serialize(cursor)
        case cursor
        when Time, DateTime, Date
          cursor.iso8601
        else
          cursor.to_s
        end
      end

      def limited_relation
        raise NotImplementedError
      end

      def sliced_relation
        raise NotImplementedError
      end

      def after_cursor
        @after_cursor ||= opaque_cursor ? decode(after) : after
      end

      def before_cursor
        @before_cursor ||= opaque_cursor ? decode(before) : before
      end
    end
  end
end
