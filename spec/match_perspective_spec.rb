require 'spec_helper'
require 'json'

describe MatchPerspective do
  let(:user1) { User.new(id: 1, name: 'user1') }
  let(:user2) { User.new(id: 2, name: 'user2') }
  let(:player1) { Player.with_number_and_cards(number: 1, cards: ['AS', '2C', '10D']) }
  let(:player2) { Player.with_number_and_cards(number: 2, cards: ['JH', '6S', 'KC']) }
  let(:game) { Game.new([player1, player2]) }
  let(:match) { Match.new(id: 0, game: game) }
  let(:match_user1) { MatchUser.new(match: match, user: user1, player: player1) }
  let(:match_user2) { MatchUser.new(match: match, user: user2, player: player2) }

  before do
    match.match_users << match_user1
    match.match_users << match_user2
    match.current_user = match_user2
    match.messages = ['message1', 'message2']
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
    expect(perspective.messages).to match_array ['message1', 'message2']
  end

  it 'creates well formed json for itself' do
    perspective = MatchPerspective.new(match: match, user: match_user2)
    perspective_json = perspective.to_json
    perspective_hash = JSON.parse(perspective_json, {symbolize_names: true})
    expect(perspective_hash[:status]).to eq 'pending'
    expect(perspective_hash[:name]).to eq 'user2'
    expect(perspective_hash[:messages]).to match_array ['message1', 'message2']
    expect(perspective_hash[:cards]).to match_array [
      {rank: 'J', suit: 'H'},
      {rank: '6', suit: 'S'},
      {rank: 'K', suit: 'C'}
    ]
    expect(perspective_hash[:book_count]).to eq 0
    expect(perspective_hash[:deck_card_count]).to eq 52
    expect(perspective_hash[:opponents]).to match_array [
      {name: 'user1', card_count: 3, book_count: 0}
    ]
  end
end
