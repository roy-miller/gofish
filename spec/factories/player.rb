FactoryGirl.define do
  factory :player do
    sequence(:number) { |n| n }

    transient { cards [] }
    transient { book_values [] }

    after(:build) do |player, evaluator|
      evaluator.cards.each do |card_rank_and_suit|
        rank = card_rank_and_suit.chars.first
        rank = '10' if rank == '1'
        suit = card_rank_and_suit.chars.last
        player.hand << build(:card, rank: rank, suit: suit)
      end
      evaluator.book_values.each do |value|
        book_cards = ['S','H','C','D'].map { |suit| build(:card, rank: value, suit: suit) }
        player.books << build(:book, cards: book_cards)
      end
    end
  end
end
