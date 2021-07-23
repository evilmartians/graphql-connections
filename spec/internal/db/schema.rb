# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :messages do |t|
    t.text :username, null: true
    t.text :body, null: true
    t.text :tag, null: true
    t.boolean :deleted, null: false, default: false
    t.timestamps null: false
  end
end
