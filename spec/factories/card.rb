FactoryGirl.define do
  factory :card do
    sequence(:rank) { |n| %w{2 3 4 5 6 7 8 9 10 J Q K A}[n % 13] }
    sequence(:suit) { |n| %w{S D C H}[n % 4] }

    initialize_with { new(rank: rank, suit: suit) }
  end
end
