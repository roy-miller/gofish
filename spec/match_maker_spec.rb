require 'spec_helper'

describe MatchMaker do
  context 'with no initial pending users' do
    let(:match_maker) { MatchMaker.new }
    let(:existing_user) { User.new(id: 123, name: 'existing') }

    before do
      User.reset_users
    end

    it 'adds new user to pending users' do
      match_maker.add_pending_user(id: nil, name: 'newuser')
      expect(match_maker.pending_users.count).to eq 1
      expect(User.users.count).to eq 1 # this is a side effect, is that wrong?
      expect(User.users.first.name).to eq 'newuser'
    end

    it 'adds existing user to pending users' do
      match_maker.add_pending_user(id: 123, name: 'existing')
      expect(match_maker.pending_users.count).to eq 1
      expect(User.users.count).to eq 1 # this is a side effect, is that wrong?
    end

    context 'with existing pending user' do
      before do
        match_maker.pending_users << User.new(name: 'pendinguser1')
      end

      it 'makes a game when pending users reaches target' do
        match = match_maker.add_pending_user(id: nil, name: 'pendinguser2')
        expect(match.class).to eq Match
        player_names = match.game.players.map(&:name)
        expect(player_names).to match_array ['pendinguser1', 'pendinguser2']
      end
    end
  end
end
