FactoryGirl.define do
  factory :game do
    players []
    association :deck, factory: :deck, strategy: :build

    trait :with_two_players do
      after(:build) do |game|
        game.players = build_list(:player, 2)
      end
    end

    trait :with_books do
      after(:build) do |game|
        game.players.first.books = build_list(:book, 1)
        books = build_list(:book, 2)
        game.players.last.books = books
      end
    end
  end
end
