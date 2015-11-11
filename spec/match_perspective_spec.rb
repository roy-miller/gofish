require 'spec_helper'

describe MatchPerspective do
  let(:user1) { User.new(id: 1, name: 'user1') }
  let(:user2) { User.new(id: 2, name: 'user2') }
  let(:player1) { Player.new(1) }
  let(:player2) { Player.new(2) }
  let(:game) { Game.new([player1, player2]) }
  let(:match_user1) { MatchUser.new(user: user1, player: player1) }
  let(:match_user2) { MatchUser.new(user: user2, player: player2) }
  let(:match) { Match.new(id: 0, game: game, match_users: [match_user1, match_user2]) }

  before do
    match.current_user = match_user2
    match.messages[match_user1] = []
    match.messages[match_user2] = []
  end

  it 'creates a perspective from a match' do
    perspective = MatchPerspective.new(match: match, user: match_user2)
    expect(perspective.match_id).to eq 0
    expect(perspective.you).to be match_user2
    expect(perspective.current_user).to be match_user2
    expect(perspective.initial_user).to be match_user1
    expect(perspective.player).to be player2
    expect(perspective.opponents).to match_array [match_user1]
    expect(perspective.deck_card_count).to eq 52
    expect(perspective.pending?).to be true
    expect(perspective.messages).to be_empty
  end
end
