# frozen_string_literal: true

class ApplicationSchema < GraphQL::Schema
  default_max_page_size 3

  query QueryRoot
end
