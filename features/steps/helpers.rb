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

  def wait_for_game_with_two_players
    #@match = make_match(desired_player_count: 2)
    #@me = @match.match_users.first
    #@my_hand_before_asking = Array.new(@me.player.hand)
    #ask_to_play(opponent_count: 1, player_name: 'user1', user_id: 0)
  end

  def start_game_with_three_players
    @match = make_match(desired_player_count: 3)
    add_users(count: 3, match: @match)
    @match.start
    set_instance_variables_for_tests
  end

  def start_game_with_robots(real_player_count:, robot_count:)
    @match = make_match(desired_player_count: real_player_count + robot_count)
    add_users(count: real_player_count, match: @match)
    add_users(count: robot_count, match: @match, robot: true)
    @match.start
    all_users_have_one_card
    set_instance_variables_for_tests
  end

  def all_users_have_one_card
    @match.match_users.each do |user|
      give_ten(user)
    end
  end

  def set_instance_variables_for_tests
    @me = @match.match_users.first
    @my_hand_before_asking = Array.new(@me.player.hand)
    @first_opponent = @match.opponents_for(@me).first
    @first_opponent_hand_before_asking = Array.new(@first_opponent.player.hand)
    @second_opponent = @match.opponents_for(@me).last
    @second_opponent_hand_before_asking = Array.new(@second_opponent.player.hand)
    @match.game.deck.cards = [Card.new(rank: 'Q', suit: 'H'), Card.new(rank: '10', suit: 'D')]
    @fish_card = @match.game.deck.cards.last
    @card_nobody_has = Card.new(rank: '7', suit: 'H')
  end

  def make_match(desired_player_count:)
    @match = build(:match, users: [build(:user, name: 'user1'), build(:user, name: 'user2')])
    Match.matches << @match
    @match
  end

  def add_users(count:, match:, robot: false)
    (1..count).each do |index|
      user_name = robot ? "robot#{index}" : "user#{index}"
      user = User.new(id: @match.match_users.count + 1, name: user_name)
      match_user = robot ? RobotMatchUser.new(match: match, user: user) :
                           MatchUser.new(match: match, user: user)
      match.add_user(match_user: match_user)
    end
  end

  def visit_player_page
    visit "/matches/#{@match.id}/users/#{Match.matches.first.users.first.id}"
  end

  def click_to_ask_for_cards(card)
    my_card_link = page.find(".your-card[data-rank='#{card.rank.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  def set_my_hand_before_asking
    @my_hand_before_asking = Array.new(@me.player.hand)
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

  def simulate_play_request(user:, number_of_opponents: 1, user_id: '', reset_match_maker: false)
    params = {
      user_name: user.name,
      user_id: user_id,
      number_of_opponents: number_of_opponents,
      reset_match_maker: reset_match_maker
    }
    post("/start", params)
  end

  def give_card(user:, rank:, suit: 'C')
    card = Card.new(rank: rank, suit: suit)
    user.player.add_card_to_hand(card)
    card
  end

  def give_king(user)
    give_card(user: user, rank: 'K')
  end

  def give_ten(user)
    give_card(user: user, rank: '10')
  end
end
