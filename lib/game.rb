require_relative './deck.rb'
require_relative './card.rb'
require_relative './player.rb'
require_relative './request.rb'

class Game
  attr_accessor :deck, :players, :current_player, :winner

  def initialize(players=[])
    @deck = Deck.new
    @players = players
    @winner = nil
    @current_player = players.first
  end

  def add_player(player)
    self.players << player
  end

  def deal(cards_per_player: 5)
    rand(1..5).times { self.deck.shuffle }
    self.players.each { |player| 5.times { player.add_card_to_hand(deck.give_top_card) } }
  end

  def advance_play
    current_player_index = players.find_index(self.current_player)
    self.current_player = self.players[current_player_index + 1] || self.players.first
  end

  def winner
    self.players.max_by(&:book_count)
  end

  def over?
    !self.deck.has_cards?
  end

  def player_number(number)
    self.players.detect { |player| player.number == number }
  end

  def opponents_for_player(number)
    self.players.reject { |player| player.number == number }
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
    card_drawn = self.deck.give_top_card
    player.add_card_to_hand(card_drawn)
    card_drawn
  end

  def draw_card_for_player(number)
    player_number(number).add_card_to_hand(self.deck.give_top_card)
  end

  def to_hash
    hash = {}
    hash[:players] = self.players.map { |player| player.to_hash }
    hash[:winner] = self.winner.to_hash
    hash
  end

  private

  def ask_player_for_cards(player, request)
    player.receive_request(request)
  end
end
