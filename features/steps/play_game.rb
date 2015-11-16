require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::PlayGame < Spinach::FeatureSteps
  include Helpers

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'a game with three players' do
    start_game_with_three_players
  end

  step 'it is my turn' do
    @match.next_user = @me
  end

  step 'it is still my turn' do
    expect(@match.current_user).to be @me
    expect(page.has_content?("It's #{@me.name}'s turn")).to be true
  end

  step 'it becomes my turn' do
    expect(@match.current_user).to be @me
  end

  step 'I ask my first opponent for cards he has' do
    visit_player_page
    opponents = @match.opponents_for(@me)
    @expected_card = opponents.first.player.hand.first
    my_card_link = page.find(".your-card[data-rank='#{@expected_card.rank.downcase}'][data-suit='#{@expected_card.suit.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'I get the cards' do
    visit_player_page
    expected_hand = [@hand_before_asking, @expected_card].flatten
    expected_hand.each do |card|
      expect(page.has_css?(".your-card[data-rank='#{card.rank.downcase}'][data-suit='#{card.suit.downcase}']")).to be true
    end
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

  step 'I have the rank I\'ll draw' do
    @me.player.hand.pop
    give_card(user: @me, rank: @fish_card.rank)
  end

  step 'I don\'t have the rank I\'ll draw' do
    # TODO need this for test clarity?
  end

  step 'I ask my first opponent for the rank I\'ll draw' do
    visit_player_page
    my_card_link = page.find(".your-card[data-rank='#{@fish_card.rank.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'I ask my first opponent for a rank I won\'t draw' do
    visit_player_page
    my_card_link = page.find(".your-card[data-rank='j']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'it is my first opponent\'s turn' do
    @match.next_user = @match.opponents_for(@me).first
  end

  step 'it becomes my first opponent\'s turn' do
    expect(@match.current_user).to be @match.opponents_for(@me).first
  end

  step 'it is still my first opponent\'s turn' do
    expect(@match.current_user).to be @match.opponents_for(@me).first
  end

  step 'I go fishing' do
    # how can I guarantee that he doesn't get what he asked for?
    visit_player_page
    expect(@me.player.hand.count).to eq (@hand_before_asking.count + 1)
    added_card = (@me.player.hand - @hand_before_asking).first
    expect(page.has_css?(".your-card[data-rank='#{added_card.rank.downcase}'][data-suit='#{added_card.suit.downcase}']")).to be true
  end

  step 'I draw a card with the rank I asked for' do
    pending 'step not implemented'
  end

  step 'I draw a card with a rank different from I asked for' do
    pending 'step not implemented'
  end

  step 'my first opponent asks me for cards I have' do
    pending 'step not implemented'
  end

  step 'I give him the cards' do
    pending 'step not implemented'
  end

  step 'my first oppponent asks me for cards I do not have' do
    pending 'step not implemented'
  end

  step 'I do not give him the cards' do
    pending 'step not implemented'
  end

  step 'it is my second opponent\'s turn' do
    pending 'step not implemented'
  end

  step 'it my first opponent\'s turn' do
    pending 'step not implemented'
  end

  step 'my first opponent asks my second opponent for cards he has' do
    pending 'step not implemented'
  end

  step 'my first opponent gets the cards' do
    pending 'step not implemented'
  end

  step 'my first opponent asks my second opponent for cards he does not have' do
    pending 'step not implemented'
  end

  step 'my first opponent does not get the cards' do
    pending 'step not implemented'
  end
end
