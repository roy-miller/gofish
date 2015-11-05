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

  it 'adds a match when the match does not already exist' do
    added_match = Match.new(id: 0, game: nil, match_users: [])
    Match.add_match(added_match)
    expect(Match.matches.count).to eq 1
    expect(Match.matches).to match_array [added_match]
  end

  it 'does not add a match when the match already exists' do
    existing_match = Match.new(id: 0, game: nil, match_users: [])
    Match.matches << existing_match
    Match.add_match(existing_match)
    expect(Match.matches.count).to eq 1
    expect(Match.matches).to match_array [existing_match]
  end

  context 'initialized' do
    let(:match) { Match.new(id: 0, game: nil, match_users: []) }
    let(:first_user) { User.new(id: 123, name: 'existing') }
    let(:first_match_user) { MatchUser.new(user: first_user) }

    before do
      Match.matches << match
    end

    it 'says match is pending when created' do
      expect(match.pending?).to be true
    end

    it 'gives back the first pending match' do
      pending_match = Match.first_pending
      expect(pending_match).to be match
    end

    it 'adds a match user' do
      match.add_user(first_match_user)
      expect(match.match_users).to match_array [first_match_user]
      expect(match.next_player_number).to eq 2
    end

    context 'with one user' do
      let(:second_user) { User.new(name: 'added') }
      let(:second_match_user) { MatchUser.new(user: second_user) }

      before do
        match.add_user(first_match_user)
      end

      it 'makes a game when added user makes enough for a game' do
        match.add_user(second_match_user)
        expect(match.game.players.count).to eq 2
        expect(match.pending?).to be false
        expect(match.started?).to be true
      end
    end
  end

  context 'with a game and users' do
    let(:game) { Game.new }
    let(:first_match_user_added) { MatchUser.new(user: User.new(id: 1, name: 'user1')) }
    let(:second_match_user_added) { MatchUser.new(user: User.new(id: 2, name: 'user2')) }
    let(:match) { Match.new(game: game, match_users: [first_match_user_added, second_match_user_added]) }

    before do
      Match.matches << match
    end

    it 'finds existing match for given match id' do
      expect(Match.matches.count).to eq 1
      found_match = Match.find(0)
      expect(Match.matches.count).to eq 1
    end

    it 'finds existing match for given user id' do
      found_match = Match.find_for_user(2)
      expect(found_match).to be match
    end

    it 'is over if its game is over' do
      allow(game).to receive(:over?) { true }
      expect(match.over?).to be_truthy
    end

    it 'initially sets current user to first user added' do
      expect(match.current_user).to be first_match_user_added
    end

    it 'tells its user names' do
      expect(match.user_names).to match_array ['user1', 'user2']
    end

    it 'moves play to the next user after the current one when asked' do
      match.current_user = match.match_users.first
      expect(match.move_play_to_next_user).to be second_match_user_added
      expect(match.move_play_to_next_user).to be first_match_user_added
    end

    it 'answers user with given name' do
      user = match.user_with_name('user2')
      expect(user).to be second_match_user_added
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
        player = match.player_for(second_match_user_added.id)
        expect(player).to be player2
      end

      it 'finds all opponents for a given user id' do
        opponents = match.opponents_for(second_match_user_added.id)
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

      context 'with cards for players' do
        before do
          player1_card1 = Card.new(rank: '8', suit: 'D')
          player1_card2 = Card.new(rank: 'J', suit: 'S')
          player1.hand << player1_card1
          player1.hand << player1_card2

          player2_card1 = Card.new(rank: 'A', suit: 'C')
          player2_card2 = Card.new(rank: 'A', suit: 'H')
          player2_card3 = Card.new(rank: 'A', suit: 'D')
          player2.hand << player2_card1
          player2.hand << player2_card2
          player2.hand << player2_card3

          player2_book1 = Book.new
          player2_book1.add_card(Card.new(rank: '4', suit: 'C'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'H'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'D'))
          player2_book1.add_card(Card.new(rank: '4', suit: 'S'))
          player2.books << player2_book1
        end

        it 'provides the current state of the match' do
          expected_state = 'user1 has 2 cards and these books: [  ]' +
                           "\n" +
                           'user2 has 3 cards and these books: [ 4s ]'
          expect(match.state).to eq expected_state
        end

        it 'provides the current state for a single user' do
          expected_state = 'you have these cards: 8D, JS and these books: [  ]'
          expect(match.state_for(first_match_user_added)).to eq expected_state
        end
      end
    end
  end
end
