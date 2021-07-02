# frozen_string_literal: true

module GraphQL
  module Connections
    module Keyset
      class Base < ::GraphQL::Connections::Base
        attr_reader :field_key

        SEPARATOR = '/'

        def initialize(*args, field_key: nil, primary_key: nil, separator: SEPARATOR, **kwargs)
          @primary_key = primary_key
          @field_key = field_key
          @separator = separator

          super(*args, **kwargs)
        end

        def cursor_for(item)
          cursor = [item[field_key], item[primary_key]].map { |value| serialize(value) }.join(@separator)
          cursor = encode(cursor) if opaque_cursor
          cursor
        end

        private

        def sliced_relation
          items
            .yield_self { |s| after ? sliced_relation_after(s) : s }
            .yield_self { |s| before ? sliced_relation_before(s) : s }
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
end
