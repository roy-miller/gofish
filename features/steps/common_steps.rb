module CommonSteps
  include Spinach::DSL

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

  step 'it is my first opponent\'s turn' do
    @match.current_user = @first_opponent
  end

  step 'it becomes my first opponent\'s turn' do
    expect(@match.current_user).to be @first_opponent
  end

  step 'it is still my first opponent\'s turn' do
    expect(@match.current_user).to be @first_opponent
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

end

# module CommonSteps
#   module Parameterized
#     include Spinach::DSL
#
#     def play_game_steps(player_count, *player_names)
#       player_names.each do |player_name|
#         step "#{player_name} plays a #{player_count} player game" do
#           # visit '/'
#           # page.within("#game_options") do # page.* avoids rspec matcher clash
#           #   fill_in 'user_name', with: player_names
#           #   fill_in 'user_id', with: ''
#           #   select player_count, from: 'number_of_opponents'
#           #   click_button 'start_playing'
#           # end
#         end
#       end
#     end
#
#   end
# end

# module CommonSteps
#   module Paramaterized
#     def play_game(player_count, *player_names)
#       player_names.each do |name|
#         step "#{name} plays a #{player_count} player game" do
#           puts "saw #{name} of #{player_count}"
#           visit '/'
#           page.within("#game_options") do # page.* avoids rspec matcher clash
#             fill_in 'user_name', with: name
#             fill_in 'user_id', with: ''
#             select player_count, from: 'number_of_opponents'
#             click_button 'start_playing'
#           end
#         end
#       end
#     end
#   end
# end
