[![Gem Version](https://badge.fury.io/rb/graphql-connections.svg)](https://badge.fury.io/rb/graphql-connections)
[![Build Status](https://travis-ci.org/bibendi/graphql-connections.svg?branch=master)](https://travis-ci.org/bibendi/graphql-connections)

# GraphQL::Connections

Cursor-based pagination to work with `ActiveRecord::Relation`s.

Implements [Relay specification](https://relay.dev/graphql/connections.htm) for serving stable connections based on column values.
If objects are created or destroyed during pagination, the list of items won’t be disrupted.

<a href="https://evilmartians.com/?utm_source=graphql-connections">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Add this line to your application's Gemfile:

```ruby
gem "graphql-connections"
```

## Usage

You can use a stable connection wrapper on a specific field:

```ruby
field :messages, Types::Message.connection_type, null: false

def messages
  GraphQL::Connections::Stable.new(Message.all)
end
```

Records are sorted by model's primary key by default. You can change this behaviour by providing `primary_key` param:

```ruby
GraphQL::Connections::Stable.new(Message.all, primary_key: :created_at)
```

In case when you want records to be sorted by more than one field (i.e., _keyset pagination_), you can use `keys` param:

```ruby
GraphQL::Connections::Stable.new(Message.all, keys: %w[name id])
```

When you pass only one key, a primary key will be added as a second one:

```ruby
GraphQL::Connections::Stable.new(Message.all, keys: [:name])
```

**NOTE:** Currently we support maximum two keys in the keyset.

Also, you can pass the `:desc` option to reverse the relation:

```ruby
GraphQL::Connections::Stable.new(Message.all, keys: %w[name id], desc: true)
```

**NOTE:** `:desc` option is not implemented for stable connections with `:primary_key` passed; if you need it—use keyset pagination or implement `:desc` option for us 🙂.

Also, you can disable opaque cursors by setting `opaque_cursor` param:

```ruby
GraphQL::Connections::Stable.new(Message.all, opaque_cursor: false)
```

Or you can apply a stable connection to all Active Record relations returning by any field:

```ruby
class ApplicationSchema < GraphQL::Schema
  use GraphQL::Pagination::Connections

  connections.add(ActiveRecord::Relation, GraphQL::Connections::Stable)
end
```

**NOTE:** Don't use stable connections for relations whose ordering is too complicated for cursor generation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bibendi/graphql-connections.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
