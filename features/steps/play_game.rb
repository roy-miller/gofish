require_relative './common_steps.rb'
require_relative './helpers.rb'

class Spinach::Features::PlayGame < Spinach::FeatureSteps
  include Helpers

  Spinach.hooks.before_scenario { |scenario| Match.reset }

  step 'a game with three players' do
    @match = Match.make_match(3)
    (0..2).each do |user_id|
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
    @initial_hand = Array.new(@me.player.hand)
  end

  step 'it is my turn' do
    @match.next_user = @me
  end

  step 'it is still my turn' do
    expect(@match.current_user).to be @me
    expect(page.has_content?("It's #{@me.name}'s turn")).to be true
  end

  step 'it became my turn' do
    expect(@match.current_user).to be @me
  end

  step 'I ask an opponent for cards he has' do
    visit_my_page
    opponents = @match.opponents_for(@me)
    @expected_card = opponents.first.player.hand.first
    my_card_link = page.find(:css, ".your-card.#{@expected_card.rank.downcase}#{@expected_card.suit.downcase} a")
    puts "\n\n\n**********"
    #puts page.html
    puts "**********\n\n\n"
    my_card_link.click
    opponent_link = page.all('.opponent-name').first
    opponent_link.click
    #@match.ask_for_cards(requestor: @me, recipient: opponents.first, card_rank: @expected_card.rank)
  end

  step 'I get the cards' do
    visit_my_page
    expected_hand = [@initial_hand, @expected_card].flatten
    puts "\n\n\n**********"
    puts page.html
    puts "**********\n\n\n"
    expected_hand.each do |card|
      expect(page.has_css?(".your-card.#{card.rank.downcase}#{card.suit.downcase}")).to be true
    end
  end

  step 'I ask an opponent for cards he does not have' do
    opponent = @match.opponents_for(@me).first
    ranks = ['1','2','3','4','5','6','7','8','9','10','J','Q','K','A']
    rank_he_does_not_have = ranks.find { |rank| rank != opponent.player.hand.map(&:rank) }
    @expected_card = Card.new(rank: rank_he_does_not_have, suit: 'S')


    @match.ask_for_cards(requestor: @me, recipient: opponent, card_rank: @expected_card.rank)
  end

  step 'I went fishing' do
    # how can I guarantee that he doesn't get what he asked for?
    expect(@me.player.hand.count).to eq (@initial_hand.count + 1)
  end

  step 'it is my first opponent\'s turn' do
    @match.next_user = @match.opponents_for(@me).first
  end

  step 'it became my first opponent\'s turn' do
    expect(@match.current_user).to be @match.opponents_for(@me).first
  end

  step 'it is still my first opponent\'s turn' do
    expect(@match.current_user).to be @match.opponents_for(@me).first
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
