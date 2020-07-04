# frozen_string_literal: true

class QueryRoot < GraphQL::Schema::Object
  field :time, String, "Current server time", null: false

  def time
    Time.now.to_s
  end
end
