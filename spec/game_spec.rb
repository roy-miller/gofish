require 'spec_helper'

describe Game do
  let(:game) do
    game = Game.new
    game.players << Player.new('player1')
    game.players << Player.new('player2')
    game
  end
  let(:higher_rank_card) { Card.new(rank: 'Q', suit: 'S') }
  let(:lower_rank_card) { Card.new(rank: '4', suit: 'H') }

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
      game.add_player(Player.new('playername'))
      expect(game.players.count).to eq 1
    end
  end

  context 'with players' do
    let(:player1) { Player.new('player1') }
    let(:player2) { Player.new('player2') }
    let(:game) do
      game = Game.new
      game.players << player1
      game.players << player2
      game
    end

    describe '#player1' do
      it 'answers first player' do
        expect(game.player1).to eq player1
      end
    end

    describe '#player2' do
      it 'answers second player' do
        expect(game.player2).to eq player2
      end
    end

    describe '#deal' do
      it 'deals requested number of cards to each player' do
        game.deal(cards_per_player: 5)
        expect(player1.card_count).to eq 5
        expect(player2.card_count).to eq 5
        expect(game.deck.card_count).to eq 42
      end
    end

    describe '#play_round' do
    #   context 'when player1 wins' do
    #     it 'declares a result with player1 the winner, adds cards to player1' do
    #       game.players.first.hand = [higher_rank_card]
    #       game.players.last.hand = [lower_rank_card]
    #       result = game.play_round
    #       expect(result.winner).to eq player1
    #       expect(result.loser).to eq player2
    #       expect(result.cards_played[:player1]).to match_array([higher_rank_card])
    #       expect(result.cards_played[:player2]).to match_array([lower_rank_card])
    #       expect(game.players.first.hand).to include(higher_rank_card, lower_rank_card)
    #     end
    #   end
    #   context 'when player2 wins' do
    #     it 'declares a result with player2 the winner, adds cards to player2' do
    #       game.players.first.hand = [lower_rank_card]
    #       game.players.last.hand = [higher_rank_card]
    #       result = game.play_round
    #       expect(result.winner).to eq player2
    #       expect(result.loser).to eq player1
    #       expect(result.cards_played[:player1]).to match_array([lower_rank_card])
    #       expect(result.cards_played[:player2]).to match_array([higher_rank_card])
    #       expect(game.players.last.hand).to include(higher_rank_card, lower_rank_card)
    #     end
    #   end
    #   context 'when ranks are the same' do
    #     it 'declares war, adds cards to winner' do
    #       card1 = Card.new(rank: 'K', suit: 'C')
    #       card2 = Card.new(rank: '2', suit: 'S')
    #       card3 = Card.new(rank: 'J', suit: 'S')
    #       card4 = Card.new(rank: '9', suit: 'D')
    #       card5 = Card.new(rank: '8', suit: 'C')
    #       card6 = Card.new(rank: 'J', suit: 'H')
    #       game.players.first.hand = [card1, card2, card3]
    #       game.players.last.hand = [card4, card5, card6]
    #
    #       result = game.play_round
    #
    #       expect(result.winner).to eq game.players.first
    #       expect(result.loser).to eq game.players.last
    #       expect(result.cards_played[:player1]).to match_array([card1,card2,card3])
    #       expect(result.cards_played[:player2]).to match_array([card4,card5,card6])
    #       expect(game.players.first.hand).to include(card1, card2, card3, card4, card5, card6)
    #     end
    #   end
    #   it 'declares multiple wars, adds cards to winner' do
    #     card1 = Card.new(rank: '6', suit: 'H')
    #     card2 = Card.new(rank: '6', suit: 'S')
    #     card3 = Card.new(rank: 'K', suit: 'C')
    #     card4 = Card.new(rank: '3', suit: 'C')
    #     card5 = Card.new(rank: 'J', suit: 'S')
    #     card6 = Card.new(rank: '10', suit: 'D')
    #     card7 = Card.new(rank: 'A', suit: 'S')
    #     card8 = Card.new(rank: 'K', suit: 'C')
    #     card9 = Card.new(rank: '5', suit: 'D')
    #     card10 = Card.new(rank: 'J', suit: 'H')
    #     game.players.first.hand = [card1, card2, card3, card4, card5]
    #     game.players.last.hand = [card6, card7, card8, card9, card10]
    #
    #     result = game.play_round
    #
    #     expect(result.winner).to eq game.players.last
    #     expect(result.loser).to eq game.players.first
    #     expect(result.cards_played[:player1]).to match_array([card1,card2,card3,card4,card5])
    #     expect(result.cards_played[:player2]).to match_array([card6,card7,card8,card9,card10])
    #     expect(game.players.last.hand).to include(card1, card2, card3, card4, card5,
    #                                               card6, card7, card8, card9, card10)
    #   end
    #   it 'does not play if the game is over' do
    #     game.players.first.hand = [Card.new(rank: '6', suit: 'H')]
    #     game.players.last.hand = []
    #     result = game.play_round
    #     expect(result.winner).to be game.player1
    #
    #     game.players.first.hand = []
    #     game.players.last.hand = [Card.new(rank: '6', suit: 'H')]
    #     result = game.play_round
    #     expect(result.winner).to be game.player2
    #   end
    end

    describe '#over?' do
      it 'answers true when player1 is out of cards' do
        game.player1.hand = []
        expect(game.over?).to be true
      end
      it 'answers true when player2 is out of cards' do
        game.player2.hand = []
        expect(game.over?).to be true
      end
      it 'answers false when both players have cards' do
        game.player1.hand = [Card.new(rank: 'rank', suit: 'suit')]
        game.player2.hand = [Card.new(rank: 'rank', suit: 'suit')]
        expect(game.over?).to be false
      end
    end

    describe '#declare_game_winner' do
      it 'declares player1 the winner when player2 is out of cards' do
        game.player1.hand = [Card.new(rank: 'K', suit: 'C')]
        game.player2.hand = []
        winner, loser = game.declare_game_winner
        expect(winner).to be player1
        expect(loser).to be player2
      end

      it 'declares player2 the winner when player1 is out of cards' do
        game.player1.hand = []
        game.player2.hand = [Card.new(rank: 'K', suit: 'C')]
        winner, loser = game.declare_game_winner
        expect(winner).to be player2
        expect(loser).to be player1
      end
    end
  end
end
