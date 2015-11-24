FactoryGirl.define do
  factory :user do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "user#{n}" }
  end
end
