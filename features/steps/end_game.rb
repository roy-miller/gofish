require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::EndGame < Spinach::FeatureSteps
  include Helpers

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'a game with three players' do
    start_game_with_three_players
  end

  step 'a deck with one card left' do
    @match.game.deck.cards = [@card_nobody_has]
  end

  step 'it is my turn' do
    @match.current_user = @me
  end

  step 'it is my first opponent\'s turn' do
    @match.current_user = @first_opponent
  end

  step 'I have a card my first opponent does not' do
    @me.player.hand.pop
    give_card(user: @me, rank: 'J')
  end

  step 'I ask my first opponent for cards he does not have' do
    visit_player_page
    my_card_link = page.find(".your-card[data-rank='j'][data-suit='c']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'my first oppponent asks me for cards I do not have' do
    @first_opponent.player.hand.pop
    give_card(user: @first_opponent, rank: @card_nobody_has.rank, suit: @card_nobody_has.suit)
    ask_for_cards(match: @match,
                  requestor: @first_opponent,
                  requested: @me,
                  rank: @card_nobody_has.rank)
  end

  step 'my first opponent goes fishing' do
    expect(@first_opponent.player.hand.count).to eq (@first_opponent_hand_before_asking.count + 1)
  end

  step 'I go fishing' do
    visit_player_page
    expect(@me.player.hand.count).to eq (@my_hand_before_asking.count + 1)
    added_card = (@me.player.hand - @my_hand_before_asking).first
    expect(page.has_css?(".your-card[data-rank='#{added_card.rank.downcase}'][data-suit='#{added_card.suit.downcase}']")).to be true
  end

  step 'the match tells me the game is over' do
    visit_player_page
    expect(page.has_content?(/game over/i)).to be true
  end
end
