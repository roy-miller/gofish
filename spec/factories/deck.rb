FactoryGirl.define do
  factory :deck do
    cards { [] }

    trait(:full) do
      cards { %w{S H C D}.map do |suit|
        %w{2 3 4 5 6 7 8 9 10 J Q K A}.map do |rank|
          build(:card, rank: rank, suit: suit)
        end
      end.flatten.shuffle }
    end

    transient { card_strings [] }

    after(:build) do |deck, evaluator|
      evaluator.card_strings.each do |card_string|
        rank = card_string.chars.first
        rank = '10' if rank == '1'
        suit = card_string.chars.last
        deck.cards << build(:card, rank: rank, suit: suit)
      end
    end

    factory :deck_full_of_playing_cards, traits: [:full]
  end
end
