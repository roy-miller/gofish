require 'spec_helper'

describe Match do
  before do
    Match.matches = []
  end

  it 'adds a match' do
    added_match = Match.new(id: 0, game: nil, match_users: [])
    Match.add_match(added_match)
    expect(Match.matches.count).to eq 1
    expect(Match.matches).to match_array [added_match]
  end

  it 'creates a game with correct number of players when match is new' do
    Match.add_user(id: 1, name: 'user1', opponent_count: 1)
    created_game = Match.matches.first.game
    expect(created_game.players.count).to be 2
    expect(Match.matches.first.match_users.first.player).to be created_game.players.first
  end

  context 'initialized' do
    let(:match) { Match.new(id: 0, game: nil, match_users: []) }
    let(:first_user) { User.new(id: 1, name: 'existing') }
    let(:first_match_user) { MatchUser.new(user: first_user) }

    before do
      Match.matches << match
    end

    it 'says match is pending when created' do
      expect(match.pending?).to be true
    end

    it 'queues up messages for a match users' do
      match.broadcast('message1')
      match.broadcast('message2')
      expect(match.messages).to match_array ['message1', 'message2']
    end
  end

  context 'with a game and users' do
    let(:game) { Game.new }
    let(:match) { Match.new(game: game) }
    let(:first_match_user_added) { MatchUser.new(match: match, user: User.new(id: 1, name: 'user1')) }
    let(:second_match_user_added) { MatchUser.new(match: match, user: User.new(id: 2, name: 'user2')) }

    before do
      match.match_users = [first_match_user_added, second_match_user_added]
      match.current_user = first_match_user_added
      Match.matches << match
    end

    it 'finds existing match for given match id' do
      expect(Match.matches.count).to eq 1
      found_match = Match.find(0)
      expect(Match.matches.count).to eq 1
    end

    it 'is over if its game is over' do
      allow(game).to receive(:over?) { true }
      expect(match.over?).to be_truthy
    end

    context 'with players in the game' do
      let(:player1) { Player.new(1) }
      let(:player2) { Player.new(2) }

      before do
        game.players << player1
        game.players << player2
        first_match_user_added.player = player1
        second_match_user_added.player = player2
      end

      it 'finds the right player for a given user id' do
        player = match.player_for(second_match_user_added)
        expect(player).to be player2
      end

      it 'finds all opponents for a given user id' do
        opponents = match.opponents_for(second_match_user_added)
        expect(opponents).to match_array [first_match_user_added]
      end

      context 'with cards for players' do
        before do
          @player1_card1 = Card.new(rank: '8', suit: 'D')
          @player1_card2 = Card.new(rank: 'J', suit: 'S')
          player1.hand << @player1_card1
          player1.hand << @player1_card2

          @player2_card1 = Card.new(rank: 'A', suit: 'C')
          @player2_card2 = Card.new(rank: 'A', suit: 'H')
          @player2_card3 = Card.new(rank: 'A', suit: 'D')
          @player2_card4 = Card.new(rank: 'J', suit: 'H')
          player2.hand << @player2_card1
          player2.hand << @player2_card2
          player2.hand << @player2_card3
          player2.hand << @player2_card4

          player2_book1 = Book.new
          player2_book1.add_card(Card.new(rank: '4', suit: 'C'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'H'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'D'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'S'))
          player2.books << player2_book1
        end

        it 'provides current state of the match for a given user' do
          perspective = match.state_for(first_match_user_added)
          expect(perspective.you).to be first_match_user_added
          expect(perspective.opponents).to match_array [second_match_user_added]
          expect(perspective.status).to eq Status::PENDING
          expect(perspective.player).to be player1
          expect(perspective.current_user).to be first_match_user_added
          expect(perspective.initial_user).to be first_match_user_added
        end

        it 'moves play to the next user after the current one when next has cards' do
          match.current_user = match.match_users.first
          match.move_play_to_next_user
          expect(match.current_user).to be second_match_user_added
          match.move_play_to_next_user
          expect(match.current_user).to be first_match_user_added
        end

        it 'asks user for cards when user has no cards of requested rank' do
          match.ask_for_cards(requestor: first_match_user_added, recipient: second_match_user_added, card_rank: '8')
          expect(match.match_users.first.player.hand.count).to eq 3
          expect(match.match_users.first.player.hand).to include(@player1_card1, @player1_card2)
          expect(match.match_users.last.player.hand).to match_array [
            @player2_card1,
            @player2_card2,
            @player2_card3,
            @player2_card4
          ]
        end

        it 'asks user for cards when user has cards of requested rank' do
          match.ask_for_cards(requestor: first_match_user_added, recipient: second_match_user_added, card_rank: 'J')
          expect(match.match_users.first.player.hand).to match_array [
            @player1_card1,
            @player1_card2,
            @player2_card4
          ]
          expect(match.match_users.last.player.hand).to match_array [
            @player2_card1,
            @player2_card2,
            @player2_card3
          ]
        end

        it 'clears messages before match starts' do
          match.messages = ['message1', 'message2']
          match.start
          expect(match.messages).not_to include('message1', 'message2')
        end

        it 'clears messages before a player asks for a card' do
          match.messages = ['message1', 'message2']
          match.ask_for_cards(requestor: first_match_user_added, recipient: first_match_user_added, card_rank: 'A')
          expect(match.messages).not_to include('message1', 'message2')
        end
      end
    end
  end
end
