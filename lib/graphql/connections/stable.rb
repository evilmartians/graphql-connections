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
    module Stable
      def self.new(*args, desc: false, keys: nil, **kwargs)
        if kwargs[:primary_key] || keys.nil?
          klass = desc ? GraphQL::Connections::Key::Desc : GraphQL::Connections::Key::Asc
          return klass.new(*args, **kwargs)
        end

        raise ArgumentError, "keyset for more that 2 keys is not implemented yet" if keys.length > 2

        klass = desc ? GraphQL::Connections::Keyset::Desc : GraphQL::Connections::Keyset::Asc
        klass.new(*args, **kwargs.merge(keys: keys))
      end
    end
  end
end
