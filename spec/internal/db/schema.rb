# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :messages do |t|
    t.text :body, null: false
  end
end
