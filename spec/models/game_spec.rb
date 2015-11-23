require 'spec_helper'

describe Game do
  context 'new game with no players' do
    let(:game) { build(:game) }

    it 'creates a game with a deck of playing cards and no players' do
      expect(game.deck.cards.count).to eq 52
      expect(game.players).to be_empty
    end

    it 'adds player' do
      game.add_player(build(:player))
      expect(game.players.count).to eq 1
    end
  end

  context 'game with players' do
    let(:game) { Game.new }

    before do
      game.players << Player.new(1)
      game.players << Player.new(2)
    end

    it 'deals requested number of cards to each player' do
      #puts "BEFORE player #{game.players.first.number} #{game.players.first.object_id} starts with #{game.players.first.hand.count} cards"
      #puts "BEFORE player #{game.players.last.number} #{game.players.last.object_id} starts with #{game.players.last.hand.count} cards"
      game.deal(cards_per_player: 5)
      #puts "AFTER player #{game.players.first.number} #{game.players.first.object_id} ends with #{game.players.first.hand.count} cards"
      #puts "AFTER player #{game.players.last.number} #{game.players.last.object_id} ends with #{game.players.last.hand.count} cards"
      expect(game.players.first.card_count).to eq 5
      expect(game.players.last.card_count).to eq 5
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
      player = game.player_number(game.players.last.number)
      expect(player).to be game.players.last
    end

    it 'answers all opponents for player number' do
      opponents = game.opponents_for_player(game.players.first.number)
      expect(opponents).to match_array [game.players.last]
    end

    it 'sends a card request to the right player' do
      game.players.first.hand = [build(:card, rank: 'J', suit: 'D')]
      game.players.last.hand = [build(:card, rank: 'J', suit: 'H')]
      allow(game.players.last).to receive(:receive_request).and_call_original
      response = game.request_cards(game.players.first, game.players.last, 'J')
      expect(game.players.last).to have_received(:receive_request)
      expect(response.cards_returned?).to be true
    end

    it 'draws a card for a given player' do
      card_drawn = game.deck.cards.last
      game.draw_card(game.players.first)
      expect(game.players.first.hand).to match_array [card_drawn]
    end
  end

  context 'game with players and with books' do
    let(:game) { build(:game, :with_two_players, :with_books) }

    it 'declares a game winner' do
      expect(game.winner).to be game.players.last
    end

    it 'provides a hash of itself' do
      game_hash = game.to_hash
      game.players.each do |player|
        expect(game_hash[:players]).to include(player.to_hash)
      end
      expect(game_hash[:winner]).to eq game.winner.to_hash
    end
  end
end
