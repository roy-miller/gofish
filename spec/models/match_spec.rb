require 'spec_helper'

describe Match do
  let(:match) { build(:match, users: build_list(:user, 2)) }

  before do
    Match.matches = []
    match # only approach I could find for testing class managed persistence
  end

  it 'adds a match' do
    expect(Match.matches.count).to eq 1
    expect(Match.matches).to match_array [match]
  end

  it 'creates a game with correct number of players when match is new' do
    created_game = Match.matches.first.game
    expect(created_game.players.count).to be 2
  end

  context 'existing match' do
    before do
      Match.matches << match
      match.current_user = match.users.first
    end

    it 'finds existing match for given match id' do
      found_match = Match.find(match.id)
      expect(found_match).to be match
    end

    it 'says match is pending when created' do
      expect(match.pending?).to be true
    end

    it 'queues up messages for a match users' do
      match.add_message('message1')
      match.add_message('message2')
      expect(match.messages).to match_array ['message1', 'message2']
    end

    it 'is over if its game is over' do
      allow(match.game).to receive(:over?) { true }
      expect(match.over?).to be_truthy
    end

    it 'finds the right player for a given user id' do
      player = match.player_for(match.users.first)
      expect(player).to be match.match_users.first.player
    end

    it 'finds all opponents for a given user id' do
      opponents = match.opponents_for(match.users.first)
      expect(opponents).to match_array [match.users.last]
    end

    it 'provides current state of the match for a given user' do
      perspective = match.state_for(match.users.first)
      expect(perspective).to be_instance_of MatchPerspective
      expect(perspective.player).to be match.player_for(match.users.first)
    end

    it 'moves play to the next user after the current one when next has cards' do
      match.current_user = match.users.first
      match.move_play_to_next_user
      expect(match.current_user).to be match.users.last
      match.move_play_to_next_user
      expect(match.current_user).to be match.users.first
    end

    it 'identifies the winning user' do
      winner = match.users.first
      match.game.winner = match.player_for(winner)
      expect(match.winner).to be winner
    end

    it 'asks for cards, updates player hands when user has no cards of requested rank' do
      match.match_users.first.player.hand = [build(:card, rank: 'A', suit: 'S')]
      match.match_users.last.player.hand = [build(:card, rank: 'J', suit: 'D')]
      match.ask_for_cards(requestor: match.users.first, recipient: match.users.last, card_rank: '8')
      expect(match.match_users.first.player.hand.count).to eq 2
      expect(match.match_users.last.player.hand.count).to eq 1
    end

    it 'asks user for cards when user has cards of requested rank' do
      match.match_users.first.player.hand = [build(:card, rank: 'A', suit: 'S')]
      requested_card = build(:card, rank: 'A', suit: 'D')
      match.match_users.last.player.hand = [requested_card]
      match.ask_for_cards(requestor: match.users.first, recipient: match.users.last, card_rank: 'A')
      expect(match.match_users.first.player.hand.count).to eq 2
      expect(match.match_users.first.player.hand).to include(requested_card)
      expect(match.match_users.last.player.hand.count).to eq 0
    end

    it 'clears messages before match starts' do
      match.messages = ['message1', 'message2']
      match.start
      expect(match.messages).not_to include('message1', 'message2')
    end

    it 'clears messages before a player asks for a card' do
      match.messages = ['message1', 'message2']
      match.ask_for_cards(requestor: match.users.first, recipient: match.users.last, card_rank: 'A')
      expect(match.messages).not_to include('message1', 'message2')
    end
  end
end
