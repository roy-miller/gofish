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
    @match = Match.make_match(3)
    (1..3).each do |user_id|
      user = User.find(user_id) || User.new(id: user_id, name: "user#{user_id}")
      match_user = MatchUser.new(user: user)
      @match.add_user(match_user: match_user, opponent_count: 2)
    end
    @match.match_users.each do |match_user|
      match_user.player.hand = [
        Card.new(rank: 'A', suit: 'S'),
        Card.new(rank: '9', suit: 'C'),
        Card.new(rank: '2', suit: 'D')
      ]
    end
    @match.start
    @me = @match.match_users.first
    @hand_before_asking = Array.new(@me.player.hand)
    @match.game.deck.cards = [Card.new(rank: 'Q', suit: 'H'), Card.new(rank: '10', suit: 'D')]
    @fish_card = @match.game.deck.cards.last
  end

  def visit_player_page
    visit "/matches/#{@match.id}/users/#{Match.matches.first.match_users.first.id}"
  end

  def ask_for_cards(match, requestor, requested, rank)
    params = {
      match_id: match.id,
      requestor_id: requestor.id,
      requested_id: requested.id,
      rank: rank
    }
    post "/request_card", params
  end

  def give_card(user:, rank:, suit: 'C')
    card = Card.new(rank: rank, suit: suit)
    user.player.add_card_to_hand(card)
    card
  end
end
