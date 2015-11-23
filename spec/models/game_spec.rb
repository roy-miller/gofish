require 'spec_helper'

describe Game do
  context 'new game with no players' do
    let(:game) { Game.new }

    it 'creates a game with a deck of playing cards and no players' do
      game = Game.new
      expect(game.deck.cards.count).to eq 52
      expect(game.players).to be_empty
    end

    it 'adds player' do
      game = Game.new
      game.add_player(Player.new)
      expect(game.players.count).to eq 1
    end
  end

  context 'game with players' do
    let(:game) { Game.new }
    let(:player1) { Player.new(1) }
    let(:player2) { Player.new(2) }

    before do
      game.add_player(player1)
      game.add_player(player2)
    end

    it 'deals requested number of cards to each player' do
      game.deal(cards_per_player: 5)
      expect(player1.card_count).to eq 5
      expect(player2.card_count).to eq 5
      expect(game.deck.card_count).to eq 42
    end

    it 'deals different cards to each game player every time' do
      game.deal(cards_per_player: 5)
      cards_dealt_first_time = game.players.first.hand
      game.players.first.hand = []
      game.players.last.hand = []
      game.deal(cards_per_player: 5)
      cards_dealt_second_time = game.players.first.hand
      expect(cards_dealt_second_time).not_to match_array(cards_dealt_first_time)
    end

    it 'answers true when the deck is out of cards, even if players have cards' do
      game.deck.cards = []
      game.players.first.hand = [Card.new(rank: 'rank', suit: 'suit')]
      game.players.last.hand = [Card.new(rank: 'rank', suit: 'suit')]
      expect(game.over?).to be true
    end

    it 'answers player for number' do
      expect(game.player_number(2)).to be player2
    end

    it 'answers all opponents for player number' do
      expect(game.opponents_for_player(1)).to match_array [player2]
    end

    it 'sends a card request to the right player' do
      game.players.first.hand = [build(:card, rank: 'J', suit: 'D')]
      game.players.last.hand = [build(:card, rank: 'J', suit: 'H')]
      allow(player2).to receive(:receive_request).and_call_original
      response = game.request_cards(player1, player2, 'J')
      expect(player2).to have_received(:receive_request)
      expect(response.cards_returned?).to be true
    end

    it 'draws a card for a given player' do
      card_drawn = game.deck.cards.last
      game.draw_card(player1)
      expect(player1.hand).to match_array [card_drawn]
    end

    it 'declares a game winner' do
      player1.books << Book.new
      player2.books << Book.new
      player2.books << Book.new
      expect(game.winner).to be player2
    end
  end
end
