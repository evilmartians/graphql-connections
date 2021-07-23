# frozen_string_literal: true

FactoryBot.define do
  factory :message, class: "Message" do
    sequence(:username) { |n| Faker::Internet.unique.username(specifier: 3..32, separators: %w[.]) }
    body { Faker::Movies::LordOfTheRings.quote }

    trait :deleted do
      deleted { true }
    end
  end
end
