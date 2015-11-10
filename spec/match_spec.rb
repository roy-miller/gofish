require 'spec_helper'

describe Match do
  before do
    Match.matches = []
  end

  it 'makes a default match when it finds no match' do
    expect(Match.matches.count).to eq 0
    found_match = Match.find('nonexistent')
    expect(Match.matches.count).to eq 1
    match_user_names = found_match.match_users.map { |match_user| match_user.name }
    game_player_numbers = found_match.match_users.map { |match_user| match_user.player.number }
    expect(match_user_names).to match_array ['Player1', 'Player2']
    expect(game_player_numbers).to match_array [1, 2]
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

    it 'queues up messages for a match user' do
      match.messages[first_match_user] = []
      match.inform_user(first_match_user, message: 'message1')
      match.inform_user(first_match_user, message: 'message2')
      expect(match.messages[first_match_user]).to match_array ['message1', 'message2']
    end

    it 'provides messages for a match user and removes them' do
      match.messages[first_match_user] = []
      match.inform_user(first_match_user, message: 'message1')
      match.inform_user(first_match_user, message: 'message2')
      expect(match.messages_for(first_match_user)).to match_array ['message1', 'message2']
      expect(match.messages[first_match_user]).to be_empty
    end
  end

  context 'with a game and users' do
    let(:game) { Game.new }
    let(:first_match_user_added) { MatchUser.new(user: User.new(id: 1, name: 'user1')) }
    let(:second_match_user_added) { MatchUser.new(user: User.new(id: 2, name: 'user2')) }
    let(:match) { Match.new(game: game) }

    before do
      match.match_users = [first_match_user_added, second_match_user_added]
      match.messages[first_match_user_added] = []
      match.messages[second_match_user_added] = []
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

    it 'tells its user names' do
      expect(match.user_names).to match_array ['user1', 'user2']
    end

    it 'answers user with given name' do
      user = match.user_with_name('user2')
      expect(user).to be second_match_user_added
    end

    it 'broadcasts to all users' do
      match.broadcast('universal message')
      expect(match.messages_for(first_match_user_added)).to match_array ['universal message']
      expect(match.messages_for(second_match_user_added)).to match_array ['universal message']
    end

    it 'finds a match containing user with the given id' do
      found_match = Match.find_for_user_id(1)
      expect(found_match).to be match
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

      it 'deals the right number of cards to each game player' do
        match.deal
        expect(game.players.first.card_count).to eq 5
      end

      it 'deals different cards to each game player every time' do
        match.deal
        cards_dealt_first_time = game.players.first.hand
        game.players.first.hand = []
        game.players.last.hand = []
        match.deal
        cards_dealt_second_time = game.players.first.hand
        expect(cards_dealt_second_time).not_to match_array(cards_dealt_first_time)
      end

      xit 'associates the right game player with an added match user'

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

        # it 'provides the current state of the match' do
        #   expected_state = 'user1 has 2 cards and these books: [  ]' +
        #                    "\n" +
        #                    'user2 has 3 cards and these books: [ 4s ]'
        #   expect(match.state).to eq expected_state
        # end
        #
        # it 'provides the current state for a single user' do
        #   expected_state = 'you have these cards: 8D, JS and these books: [  ]'
        #   expect(match.state_for(first_match_user_added)).to eq expected_state
        # end

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
          match.ask_for_cards(requestor: second_match_user_added, recipient: first_match_user_added, card_rank: 'J')
          expect(match.match_users.first.player.hand).to match_array [
            @player1_card1
          ]
          expect(match.match_users.last.player.hand).to match_array [
            @player2_card1,
            @player2_card2,
            @player2_card3,
            @player2_card4,
            @player1_card2
          ]
        end
      end
    end
  end
end
