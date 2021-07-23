# frozen_string_literal: true

module GraphQL
  module Connections
    class Chewy < ::GraphQL::Pagination::RelationConnection
      private

      def load_nodes
        @nodes ||= limited_nodes.objects
      end

      def relation_count(relation)
        offset = relation_offset(relation) || 0
        limit = relation_limit(relation)
        count = relation.count - offset

        if limit.nil?
          count
        else
          [count, limit].min
        end
      end

      def relation_limit(relation)
        relation.send(:raw_limit_value)&.to_i
      end

      def relation_offset(relation)
        relation.send(:raw_offset_value)&.to_i
      end

      def null_relation(relation)
        relation.none
      end
    end
  end
end
