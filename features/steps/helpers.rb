module Helpers
  include Spinach::DSL
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def in_browser(name)
    old_session = ::Capybara.session_name
    ::Capybara.session_name = name
    yield
    ::Capybara.session_name = old_session
  end

  def ask_to_play(opponent_count: 1, player_name: 'player1', user_id: 0)
    visit '/'
    page.within("#game_options") do # page.* avoids rspec matcher clash
      fill_in 'user_name', with: player_name
      fill_in 'user_id', with: user_id
      select opponent_count, from: 'number_of_opponents'
      click_button 'start_playing'
    end
  end

  def start_game_with_three_players
    @match = make_match_with_users(humans: 3)
    @match.start
    deck_has_two_cards
    all_users_have_two_cards
    set_instance_variables_for_tests
    @match.save!
  end

  def start_game_with_robots(humans:, robots:)
    @match = make_match_with_users(humans: humans, robots: robots)
    @match.start
    deck_has_two_cards
    all_users_have_one_card
    set_instance_variables_for_tests
    @match.save!
  end

  def deck_has_two_cards
    @match.game.deck.cards = [build(:card, rank: '2', suit: 'S'), build(:card, rank: '3', suit: 'S')]
  end

  def all_users_have_two_cards
    @match.users.each do |user|
      @match.player_for(user).hand = []
      give_ten(user)
      give_king(user)
    end
  end

  def all_users_have_one_card
    @match.users.each do |user|
      @match.player_for(user).hand = []
      give_ten(user)
    end
  end

  def set_instance_variables_for_tests
    @me = @match.users.first
    @my_hand_before_asking = Array.new(@match.player_for(@me).hand)
    @first_opponent = @match.opponents_for(@me).first
    @first_opponent_hand_before_asking = Array.new(@match.player_for(@first_opponent).hand)
    @second_opponent = @match.opponents_for(@me).last
    @second_opponent_hand_before_asking = Array.new(@match.player_for(@second_opponent).hand)
    @fish_card = @match.game.deck.cards.last
    @card_nobody_has = build(:card, rank: 'A', suit: 'H')
  end

  def make_match_with_users(humans: 0, robots: 0)
    human_users = create_list(:user, humans)
    robot_users = create_list(:robot_user, robots)
    users = human_users.concat(robot_users)
    @match = create(:match, :users_have_no_cards, users: users)
    robot_users.each do |robot|
      @match.add_observer(robot)
    end
    @match
  end

  def visit_player_page
    @match.reload
    visit "/matches/#{@match.id}/users/#{@me.id}"
  end

  def click_to_ask_for_cards(card)
    my_card_link = page.find(".your-card[data-rank='#{card.rank.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  def set_my_hand_before_asking
    @my_hand_before_asking = Array.new(@match.player_for(@me).hand)
  end

  def set_current_player(user)
    @match.game.current_player = @match.player_for(user)
    @match.save!
  end

  #see http://www.elabs.se/blog/34-capybara-and-testing-apis
  def simulate_card_request(match:, requestor:, requested:, rank:)
    params = {
      match_id: match.id,
      requestor_id: requestor.id,
      requested_id: requested.id,
      rank: rank
    }
    post("/request_card", params)
  end

  def simulate_play_request(user:, number_of_opponents: 1, user_id: '', reset_match_maker: false, match_maker_timeout: 0)
    params = {
      user_name: user.name,
      user_id: user_id,
      number_of_opponents: number_of_opponents,
      reset_match_maker: reset_match_maker,
      match_maker_timeout: match_maker_timeout
    }
    post("/start", params)
  end

  def give_card(user:, rank:, suit: 'C')
    card = build(:card, rank: rank, suit: suit)
    @match.player_for(user).add_card_to_hand(card)
    card
  end

  def give_king(user)
    give_card(user: user, rank: 'K')
  end

  def give_ten(user)
    give_card(user: user, rank: '10')
  end
end
