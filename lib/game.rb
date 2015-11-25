require_relative './deck.rb'
require_relative './card.rb'
require_relative './player.rb'
require_relative './request.rb'

class Game
  attr_accessor :deck, :players, :winner

  def initialize(players=[])
    @deck = Deck.new
    @players = players
    @winner
  end

  def add_player(player)
    @players << player
  end

  def deal(cards_per_player: 5)
    rand(1..5).times { @deck.shuffle }
    @players.each do |player|
      cards_per_player.times do |i|
        card = deck.give_top_card
        player.add_card_to_hand(card)
      end
    end
  end

  def winner
    @players.max_by(&:book_count)
  end

  def over?
    !@deck.has_cards?
  end

  def player_number(number)
    @players.detect { |player| player.number == number }
  end

  def opponents_for_player(number)
    @players.reject { |player| player.number == number }
  end

  def request_cards(requestor, recipient, rank)
    request = Request.new(requestor: requestor, recipient: recipient, card_rank: rank)
    response = ask_player_for_cards(recipient, request)
    give_cards_to_player(response.requestor, response) if response.cards_returned?
    response
  end

  def give_cards_to_player(player, response)
    player.receive_response(response)
  end

  def draw_card(player)
    card_drawn = @deck.give_top_card
    player.add_card_to_hand(card_drawn)
    card_drawn
  end

  def draw_card_for_player(number)
    player_number(number).add_card_to_hand(@deck.give_top_card)
  end

  def to_hash
    hash = {}
    hash[:players] = @players.map { |player| player.to_hash }
    hash[:winner] = winner.to_hash
    hash
  end

  private

  def ask_player_for_cards(player, request)
    player.receive_request(request)
  end
end
