FactoryGirl.define do
  factory :game do
    association :deck, factory: :deck, strategy: :build

    trait :two_players do
      after(:build) do |game|
        game.players = build_list(:player, 2)
      end
    end

    trait :players_have_books do
      after(:build) do |game|
        game.players.first.books = build_list(:book, 1)
        books = build_list(:book, 2)
        game.players.last.books = books
      end
    end

    trait :full_deck do
      after(:build) do |game|
        game.deck = build(:deck, :full)
      end
    end

    factory :game_with_two_players_and_full_deck, traits: [:two_players, :full_deck]
  end
end
