require 'spec_helper'

describe Match do

  context 'with a game and users' do
    let(:game) { Game.new }
    let(:first_user_added) { User.new(name: 'user1') }
    let(:second_user_added) { User.new(name: 'user2') }
    let(:match) { Match.new(game: game, users: [first_user_added, second_user_added]) }

    it 'is over if its game is over' do
      allow(game).to receive(:over?) { true }
      expect(match.over?).to be_truthy
    end

    it 'initially sets current user to first user added' do
      expect(match.current_user).to be first_user_added
    end

    it 'tells its user names' do
      expect(match.user_names).to match_array ['user1', 'user2']
    end

    it 'moves play to the next user after the current one when asked' do
      match.current_user = match.users.first
      expect(match.move_play_to_next_user).to be second_user_added
      expect(match.move_play_to_next_user).to be first_user_added
    end

    it 'answers user with given name' do
      user = match.user_with_name('user2')
      expect(user).to be second_user_added
    end

    context 'with players in the game' do
      let(:player1) { Player.new('user1') }
      let(:player2) { Player.new('user2') }

      before do
        game.players << player1
        game.players << player2
      end

      it 'deals the right number of cards to each game player' do
        match.deal
        expect(game.players.first.card_count).to eq 5
      end

      it 'deals different cards to each game player every time' do
        match.deal
        cards_dealt_first_time = game.players.first.cards
        game.players.first.hand = []
        game.players.last.hand = []
        match.deal
        cards_dealt_second_time = game.players.first.cards
        expect(cards_dealt_second_time).not_to match_array(cards_dealt_first_time)
      end

      context 'with cards for players' do
        before do
          player1_book1 = Book.new
          player1_book1.add_card(Card.new(rank: '8', suit: 'D'))
          player1_book2 = Book.new
          player1_book2.add_card(Card.new(rank: 'J', suit: 'S'))
          player1.hand << player1_book1
          player1.hand << player1_book2

          player2_book1 = Book.new
          player2_book1.add_card(Card.new(rank: 'A', suit: 'C'))
          player2_book1.add_card(Card.new(rank: 'A', suit: 'H'))
          player2_book1.add_card(Card.new(rank: 'A', suit: 'D'))
          player2.hand << player2_book1
          player2_full_book1 = Book.new
          player2_full_book1.add_card(Card.new(rank: '4', suit: 'C'))
          player2_full_book1.add_card(Card.new(rank: '4', suit: 'H'))
          player2_full_book1.add_card(Card.new(rank: '4', suit: 'D'))
          player2_full_book1.add_card(Card.new(rank: '4', suit: 'S'))
          player2.full_books << player2_full_book1
        end

        it 'provides the current state of the match' do
          expected_state = 'user1 has 2 cards and these books: [  ]' +
                           "\n" +
                           'user2 has 3 cards and these books: [ 4s ]'
          expect(match.state).to eq expected_state
        end

        it 'provides the current state for a single user' do
          expected_state = 'you have these cards: 8D, JS and these books: [  ]'
          expect(match.state_for(first_user_added)).to eq expected_state
        end
      end
    end
  end
end
