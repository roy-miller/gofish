require 'spec_helper'

describe(Player) do
  it 'creates a player with cards given' do
    cards = ['2D', '3C', 'AS', 'JH', '10S']
    player = Player.with_number_and_cards(number: 1, cards: cards)
    expect(player.has_cards_with_rank_and_suit(cards)).to be true
  end

  let(:player) { Player.new }

  it 'creates a player with a number and no hand' do
    expect(player.number).to eq 1 # magic number?
    expect(player.hand).to be_empty
  end

  it 'responds that player is out of cards when player has no cards' do
    expect(player.out_of_cards?).to be true
  end

  context 'with hand' do
    let(:twos_card1) { Card.new(rank: '2', suit: 'D') }
    let(:twos_card2) { Card.new(rank: '2', suit: 'S') }
    let(:twos_card3) { Card.new(rank: '2', suit: 'C') }
    let(:sixes_card1) { Card.new(rank: '6', suit: 'D') }

    before do
      [twos_card1, twos_card2, twos_card3, sixes_card1].each do |card|
        player.hand << card
      end
    end

    it 'answers count of cards in hand' do
      expect(player.card_count).to eq 4
    end

    it 'responds that player is not out of cards when player has cards' do
      expect(player.out_of_cards?).to be false
    end

    it 'adds card to player hand' do
      card_to_add = Card.new(rank: 'A', suit: 'S')
      player.add_card_to_hand(card_to_add)
      expect(player.hand).to include card_to_add
    end

    it 'adds cards to player hand' do
      first_card_to_add = Card.new(rank: 'A', suit: 'S')
      second_card_to_add = Card.new(rank: '10', suit: 'D')
      player.add_cards_to_hand([first_card_to_add, second_card_to_add])
      expect(player.hand).to include first_card_to_add, second_card_to_add
    end

    it 'creates a book when added card makes four of a kind' do
      expect(player.books).to be_empty
      makes_four_of_a_kind = Card.new(rank: '2', suit: 'H')
      player.add_card_to_hand(makes_four_of_a_kind)
      expect(player.hand).not_to include twos_card1, twos_card2, twos_card3, makes_four_of_a_kind
      expect(player.books.count).to be 1
      expect(player.books.first.cards).to match_array [twos_card1, twos_card2, twos_card3, makes_four_of_a_kind]
    end

    context 'with request' do
      let(:originator) { User.new(name: 'player1') }
      let(:recipient) { User.new(name: 'player2') }
      let(:request) { Request.new(originator: originator, recipient: recipient, card_rank: nil) }

      it 'receives requests for cards, returns no cards if has none of requested rank' do
        request.card_rank = 'A'
        response = player.receive_request(request)
        expect(response).not_to be_nil
        expect(response.cards_returned?).to be false
      end

      it 'receives requests for cards, returns cards if has any of requested rank' do
        request.card_rank = '2'
        response = player.receive_request(request)
        expect(response).not_to be_nil
        expect(response.cards_returned?).to be true
        expect(response.cards_returned).to match_array [twos_card1, twos_card2, twos_card3]
        expect(player.hand).to include(sixes_card1)
        expect(player.hand).not_to include(twos_card1, twos_card2, twos_card3)
      end
    end
  end
end
