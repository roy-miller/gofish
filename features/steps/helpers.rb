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
    set_instance_variables_for_tests
  end

  def start_game_with_robots(humans:, robots:)
    @match = make_match(humans: humans, robots: robots)
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
    @me = @match.users.first
    @my_hand_before_asking = Array.new(@match.player_for(@me).hand)
    @first_opponent = @match.opponents_for(@me).first
    @first_opponent_hand_before_asking = Array.new(@match.player_for(@first_opponent).hand)
    @second_opponent = @match.opponents_for(@me).last
    @second_opponent_hand_before_asking = Array.new(@match.player_for(@second_opponent).hand)
    @match.game.deck.cards = [Card.new(rank: 'Q', suit: 'H'), Card.new(rank: '10', suit: 'D')]
    @fish_card = @match.game.deck.cards.last
    @card_nobody_has = Card.new(rank: '7', suit: 'H')
  end

  def make_match_with_users(humans: 0, robots: 0)
    users = build_list(:user, humans).concat(build_list(:robot_user, robots))
    @match = build(:match, users: users)
  end

  def visit_player_page
    visit "/matches/#{@match.id}/users/#{Match.matches.first.users.first.id}"
  end

  def click_to_ask_for_cards(card)
    my_card_link = page.find(".your-card[data-rank='#{card.rank.downcase}'][data-suit='#{card.suit.downcase}']")
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
  end

  def set_my_hand_before_asking
    @my_hand_before_asking = Array.new(@match.player_for(@me).hand)
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
