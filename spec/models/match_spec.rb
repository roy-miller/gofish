require 'spec_helper'

describe Match do
  let(:users) { create_list(:user, 2) }

  context 'with database' do
    let!(:match) { create(:match, users: users) }

    it 'saves to database successfully' do
      expect(Match.all.count).to eq 1
      expect(Match.first.id).to eq match.id
      expect(match.pending?).to be true
      expect(match.game.players.count).to eq 2
      expect(match.users.count).to eq 2
      expect(match.match_users.count).to eq 2
      expect(match.match_users.map(&:user)).to match_array users
      expect(match.messages).to be_empty
      expect(match.over?).to be false
    end

    it 'creates a game with correct number of players when match is new' do
      created_game = Match.first.game
      expect(created_game.players.count).to be 2
    end

    xit 'restores from database successfully'
  end

  context 'without database' do
    let(:match) { build(:match, users: users) }

    it 'adds and notifies observers' do
      first_observer = spy('observer1')
      second_observer = spy('observer2')
      match.add_observer(first_observer)
      match.notify_observers
      match.add_observer(second_observer)
      match.notify_observers
      expect(first_observer).to have_received(:update).twice
      expect(second_observer).to have_received(:update).once
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

    it 'finds all opponents for a given user' do
      opponents = match.opponents_for(match.users.first)
      expect(opponents).to match_array [match.users.last]
    end

    it 'provides current state of the match for a given user' do
      perspective = match.state_for(match.users.first)
      expect(perspective).to be_instance_of MatchPerspective
      expect(perspective.player).to be match.player_for(match.users.first)
    end

    it 'moves play to the next user after the current one' do
      match
      match.game.current_player = match.match_users.first.player
      match.move_play_to_next_user
      expect(match.current_player).to be match.match_users.last.user
      match.move_play_to_next_user
      expect(match.current_player).to be match.match_users.first.user
    end

    it 'identifies the winning user' do
      match.match_users.first.player.books << Book.new
      match.send(:end_match)
      expect(match.winner_id).to be users.first.id
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
