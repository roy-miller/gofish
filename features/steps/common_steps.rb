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

  step "it is my first opponent's turn" do
    @match.current_user = @first_opponent
  end

  step "it becomes my first opponent's turn" do
    expect(@match.current_user).to be @first_opponent
  end

  step "it is still my first opponent's turn" do
    page.save_screenshot("/Users/roymiller/test.png")
    expect(@match.current_user).to be @first_opponent
  end

  step 'my first opponent goes fishing' do
    expect(@match.player_for(@first_opponent).hand.count).to eq (@first_opponent_hand_before_asking.count + 1)
  end

  step 'I get the cards' do
    visit_player_page
    expected_hand = [@my_hand_before_asking, @expected_card].flatten
    expected_hand.each do |card|
      expect(page.has_css?(".your-card[data-rank='#{card.rank.downcase}'][data-suit='#{card.suit.downcase}']")).to be true
    end
  end

  step 'I go fishing' do
    visit_player_page
    expect(@match.player_for(@me).hand.count).to eq (@my_hand_before_asking.count + 1)
    added_card = (@match.player_for(@me).hand - @my_hand_before_asking).first
    expect(page.has_css?(".your-card[data-rank='#{added_card.rank.downcase}'][data-suit='#{added_card.suit.downcase}']")).to be true
  end

  step 'I have a card my first opponent does not' do
    @match.player_for(@me).hand << @card_nobody_has
    set_my_hand_before_asking
  end

  step 'I ask my first opponent for cards he does not have' do
    visit_player_page
    click_to_ask_for_cards(@card_nobody_has)
  end

  step 'my first oppponent asks me for cards I do not have' do
    @match.player_for(@first_opponent).hand << @card_nobody_has
    @first_opponent_hand_before_asking = Array.new(@match.player_for(@first_opponent).hand)
    simulate_card_request(match: @match,
                          requestor: @first_opponent,
                          requested: @me,
                          rank: @card_nobody_has.rank)
  end

  step 'my first opponent asks me for cards I have' do
    @card_opponent_asks_for = give_king(@me)
    set_my_hand_before_asking
    simulate_card_request(match: @match,
                          requestor: @first_opponent,
                          requested: @me,
                          rank: @my_hand_before_asking.last.rank)
  end

  step 'I give the cards' do
    expect(@match.player_for(@first_opponent).hand).to include(@card_opponent_asks_for)
    expect(@match.player_for(@me).hand).not_to include(@card_opponent_asks_for)
  end

  step 'I do not give the cards' do
    expect(@match.player_for(@me).hand).to match_array @my_hand_before_asking
  end

  step 'it becomes my second opponent\'s turn' do
    expect(@match.current_user).to be @second_opponent
  end

  step 'my first opponent asks my second opponent for cards he has' do
    give_king(@first_opponent)
    give_king(@second_opponent)
    simulate_card_request(match: @match,
                          requestor: @first_opponent,
                          requested: @second_opponent,
                          rank: @match.player_for(@first_opponent).hand.last.rank)
  end

  step 'the match tells me that someone asked' do
    visit_player_page
    expect(page.has_content?(/asked.*for/)).to be true
  end

  step 'the match tells me that someone went fishing' do
    expect(page.has_content?(/went fishing/)).to be true
  end

  step 'the match does not tell me that someone went fishing' do
    expect(page.has_content?(/went fishing/)).to be false
  end

  step 'my first opponent asks my second opponent for cards he does not have' do
    give_card(user: @first_opponent, rank: '7')
    simulate_card_request(match: @match,
                          requestor: @first_opponent,
                          requested: @second_opponent,
                          rank: @match.player_for(@first_opponent).hand.last.rank)
  end

end
