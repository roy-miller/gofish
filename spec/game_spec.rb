require 'spec_helper'

describe Game do
  context 'new game with no players' do
    let(:game) { Game.new }

    describe '#new' do
      it 'creates a game with a deck of playing cards and no players' do
        game = Game.new
        expect(game.deck.cards.count).to eq 52
        expect(game.players).to be_empty
      end
    end

    describe '#add_player' do
      it 'adds player' do
        game = Game.new
        game.add_player(Player.new)
        expect(game.players.count).to eq 1
      end
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

    describe '#deal' do
      it 'deals requested number of cards to each player' do
        game.deal(cards_per_player: 5)
        expect(player1.card_count).to eq 5
        expect(player2.card_count).to eq 5
        expect(game.deck.card_count).to eq 42
      end
    end

    describe '#over?' do
      it 'answers true when any player is out of cards' do
        game.players.first.hand = []
        expect(game.over?).to be true
      end
      it 'answers false when all players have cards' do
        game.players.first.hand = [Card.new(rank: 'rank', suit: 'suit')]
        game.players.last.hand = [Card.new(rank: 'rank', suit: 'suit')]
        expect(game.over?).to be false
      end
      it 'answers true when the deck is out of cards, but all players have cards' do
        game.deck.cards = []
        game.players.first.hand = [Card.new(rank: 'rank', suit: 'suit')]
        game.players.last.hand = [Card.new(rank: 'rank', suit: 'suit')]
        expect(game.over?).to be true
      end
    end

    it 'answers player for number' do
      expect(game.player_number(2)).to be player2
    end

    it 'answers all opponents for player number' do
      expect(game.opponents_for_player(1)).to match_array [player2]
    end

    it 'sends a card request to the right player' do
      recipient = User.new(name: 'player1')
      originator = User.new(name: 'player2')
      request = Request.new(originator: originator, recipient: recipient, card_rank: 'J')
      expect(player1).to receive(:receive_request).with(request).and_call_original
      response = game.ask_player_for_cards(player_number: 1, request: request)
      expect(response).not_to be_nil
    end

    it 'gives cards for player with name' do
      fives_card1 = Card.new(rank: '5', suit: 'S')
      tens_card1 = Card.new(rank: '10', suit: 'D')
      game.players.first.hand = [fives_card1, tens_card1]
      expect(game.cards_for_player(1)).to match_array([fives_card1, tens_card1])
    end

    describe '#declare_game_winner' do
      # it 'declares player1 the winner when player2 is out of cards' do
      #   game.player1.hand = [Card.new(rank: 'K', suit: 'C')]
      #   game.player2.hand = []
      #   winner, loser = game.declare_game_winner
      #   expect(winner).to be player1
      #   expect(loser).to be player2
      # end
      #
      # it 'declares player2 the winner when player1 is out of cards' do
      #   game.player1.hand = []
      #   game.player2.hand = [Card.new(rank: 'K', suit: 'C')]
      #   winner, loser = game.declare_game_winner
      #   expect(winner).to be player2
      #   expect(loser).to be player1
      # end
    end
  end
end
