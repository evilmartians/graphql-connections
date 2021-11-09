# frozen_string_literal: true

module GraphQL
  module Connections
    module Key
      # Implements pagination by one field with asc order
      class Base < ::GraphQL::Connections::Base
        def initialize(*args, primary_key: nil, **kwargs)
          @primary_key = primary_key

          super(*args, **kwargs)
        end

        def cursor_for(item)
          cursor = serialize(item[primary_key])
          cursor = encode(cursor) if opaque_cursor
          cursor
        end

        private

        def previous_items_exist?
          if last
            nodes.any? && items.where(arel_table[primary_key].lt(first_item[primary_key])).exists?
          elsif after
            items.where(arel_table[primary_key].lteq(after_cursor)).exists?
          else
            false
          end
        end

        def next_items_exist?
          if first
            nodes.any? && items.where(arel_table[primary_key].gt(last_item[primary_key])).exists?
          elsif before
            items.where(arel_table[primary_key].gteq(before_cursor)).exists?
          else
            false
          end
        end

        def first_item
          raise NotImplementedError
        end

        def last_item
          raise NotImplementedError
        end

        def apply_limit(limit, order)
          (limit.presence && sliced_relation.reorder(arel_table[primary_key].public_send(order)).limit(limit)).to_a
        end

        def sliced_relation
          @sliced_relation ||= items
            .yield_self { |s| after ? s.where(arel_table[primary_key].gt(after_cursor)) : s }
            .yield_self { |s| before ? s.where(arel_table[primary_key].lt(before_cursor)) : s }
        end
      end
    end
  end
end
