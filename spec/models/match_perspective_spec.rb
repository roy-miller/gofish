require 'spec_helper'
require 'json'

describe MatchPerspective do
  let(:user1) { build(:user) }
  let(:user2) { build(:user) }
  let(:match) { build(:match, id: 0 , users: [user1, user2]) }

  before do
    match.current_user = user1
    match.messages = ['message1', 'message2']
  end

  it 'creates a perspective from a match' do
    perspective = MatchPerspective.new(match: match, user: user1)
    expect(perspective.match_id).to eq 0
    expect(perspective.user).to be user1
    expect(perspective.player).to be match.player_for(user1)
    expected_opponents = [
      {
        name: user2.name,
        card_count: match.player_for(user2).card_count,
        book_count: match.player_for(user2).book_count
      }
    ]
    expect(perspective.opponents).to match_array expected_opponents
    expect(perspective.deck_card_count).to eq match.game.deck.card_count
    expect(perspective.pending?).to be true
    expect(perspective.messages).to match_array ['message1', 'message2']
  end

  it 'creates well formed json for itself' do
    perspective = MatchPerspective.new(match: match, user: user2)
    perspective_json = perspective.to_json
    perspective_hash = JSON.parse(perspective_json, {symbolize_names: true})
    expect(perspective_hash).to eq perspective.hash
  end
end
