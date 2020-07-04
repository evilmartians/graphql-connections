# frozen_string_literal: true

class ApplicationSchema < GraphQL::Schema
  use ::GraphQL::Execution::Interpreter
  use ::GraphQL::Analysis::AST
  use GraphQL::Pagination::Connections

  default_max_page_size 3

  query QueryRoot
end
