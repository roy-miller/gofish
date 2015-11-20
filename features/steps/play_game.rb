require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::PlayGame < Spinach::FeatureSteps
  include Helpers
  include CommonSteps

  Spinach.hooks.before_scenario do |scenario|
    Match.reset
    User.reset_users
  end

  step 'I ask my first opponent for cards' do
    card_to_request = give_king(@me)
    set_my_hand_before_asking
    visit_player_page
    click_to_ask_for_cards(card_to_request)
  end

  step 'I can\'t play' do
    visit_player_page
    expect(@me.player.hand).to match_array(@my_hand_before_asking)
  end

  step 'I ask my first opponent for cards he has' do
    give_card(user: @me, rank: 'A', suit: 'S')
    give_card(user: @first_opponent, rank: 'A', suit: 'C')
    set_my_hand_before_asking
    @expected_card = @first_opponent.player.hand.first
    visit_player_page
    click_to_ask_for_cards(@expected_card)
  end

  step 'I have the rank I\'ll draw' do
    give_card(user: @me, rank: @fish_card.rank)
    set_my_hand_before_asking
  end

  step 'I don\'t have the rank I\'ll draw' do
    # TODO need this for test clarity?
  end

  step 'I ask my first opponent for the rank I\'ll draw' do
    visit_player_page
    click_to_ask_for_cards(@fish_card)
  end

  step 'I ask my first opponent for a rank I won\'t draw' do
    visit_player_page
    my_card_link = page.find(".your-card[data-rank='j']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'my first opponent gets the cards' do
    expect(@first_opponent.player.hand).to include(@my_hand_before_asking.last)
    expect(@me.player.hand).to be_empty
  end

end
