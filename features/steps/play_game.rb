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
    @match.current_user = @me
  end

  step 'it is still my turn' do
    expect(@match.current_user).to be @me
    expect(page.has_content?("It's #{@me.name}'s turn")).to be true
  end

  step 'it becomes my turn' do
    expect(@match.current_user).to be @me
  end

  step 'I ask my first opponent for cards' do
    visit_player_page
    my_card_link = page.find(".your-card[data-rank='#{@my_hand_before_asking.first.rank.downcase}'][data-suit='#{@my_hand_before_asking.first.suit.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'I can\'t play' do
    visit_player_page
    expect(page.has_content?(/not your turn/)).to be true
  end

  step 'I ask my first opponent for cards he has' do
    visit_player_page
    @expected_card = @first_opponent.player.hand.first
    my_card_link = page.find(".your-card[data-rank='#{@expected_card.rank.downcase}'][data-suit='#{@expected_card.suit.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  step 'I get the cards' do
    visit_player_page
    expected_hand = [@my_hand_before_asking, @expected_card].flatten
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
    @match.current_user = @first_opponent
  end

  step 'it becomes my first opponent\'s turn' do
    expect(@match.current_user).to be @first_opponent
  end

  step 'it is still my first opponent\'s turn' do
    expect(@match.current_user).to be @first_opponent
  end

  step 'I go fishing' do
    # TODO how can I guarantee that he doesn't get what he asked for?
    visit_player_page
    expect(@me.player.hand.count).to eq (@my_hand_before_asking.count + 1)
    added_card = (@me.player.hand - @my_hand_before_asking).first
    expect(page.has_css?(".your-card[data-rank='#{added_card.rank.downcase}'][data-suit='#{added_card.suit.downcase}']")).to be true
  end

  step 'my first opponent asks me for cards I have' do
    ask_for_cards(match: @match,
                  requestor: @first_opponent,
                  requested: @me,
                  rank: @my_hand_before_asking.last.rank)
  end

  step 'I give him the cards' do
    expect(@first_opponent.player.hand.count).to eq 4
    expect(@first_opponent.player.hand).to include(@my_hand_before_asking.last)
    @my_hand_before_asking.pop
    expect(@me.player.hand).to match_array @my_hand_before_asking
  end

  step 'my first oppponent asks me for cards I do not have' do
    @first_opponent.player.hand.pop
    give_card(user: @first_opponent, rank: @card_nobody_has.rank, suit: @card_nobody_has.suit)
    ask_for_cards(match: @match,
                  requestor: @first_opponent,
                  requested: @me,
                  rank: @card_nobody_has.rank)
  end

  step 'I do not give him the cards' do
    expect(@me.player.hand).to match_array @my_hand_before_asking
  end

  step 'my first opponent goes fishing' do
    expect(@first_opponent.player.hand.count).to eq (@first_opponent_hand_before_asking.count + 1)
  end

  step 'it becomes my second opponent\'s turn' do
    expect(@match.current_user).to be @second_opponent
  end

  step 'my first opponent asks my second opponent for cards he has' do
    ask_for_cards(match: @match,
                  requestor: @first_opponent,
                  requested: @second_opponent,
                  rank: @first_opponent.player.hand.last.rank)
  end

  step 'my first opponent gets the cards' do
    expect(@first_opponent.player.hand.count).to eq 4
    expect(@first_opponent.player.hand).to include(@my_hand_before_asking.last)
    @my_hand_before_asking.pop
    expect(@me.player.hand).to match_array @my_hand_before_asking
  end

  step 'my first opponent asks my second opponent for cards he does not have' do
    give_card(user: @first_opponent, rank: '7')
    ask_for_cards(match: @match,
                  requestor: @first_opponent,
                  requested: @second_opponent,
                  rank: @first_opponent.player.hand.last)
  end

  step 'the match tells me that someone asked' do
    visit_player_page
    expect(page.has_content?(/asked.*for/)).to be true
  end

  step 'the match tells me that someone went fishing' do
    #visit_player_page # TODO fix the dang messages!
    expect(page.has_content?(/went fishing/)).to be true
  end

  step 'the match does not tell me that someone went fishing' do
    #visit_player_page # TODO fix the dang messages!
    expect(page.has_content?(/went fishing/)).to be false
  end
end
