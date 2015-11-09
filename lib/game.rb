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

  def deal(cards_per_player:)
    rand(1..5).times { @deck.shuffle }
    @players.each do |player|
      cards_per_player.times do |i|
        card = deck.give_top_card
        player.add_card_to_hand(card)
      end
    end
  end

  def declare_game_winner
  end

  def over?
    @players.any? { |player| player.out_of_cards? } || !@deck.has_cards?
  end

  def player_number(number)
    @players.detect { |player| player.number == number }
  end

  def opponents_for_player(number)
    @players.reject { |player| player.number == number }
  end

  def ask_player_for_cards(player_number:, request:)
    player = player_number(player_number)
    response = player.receive_request(request)
    response
  end

  def give_cards_to_player(player_number:, response:)
    player = player_number(player_number)
    player.receive_response(response)
  end

  def draw_card(player)
    player.add_card_to_hand(@deck.give_top_card)
  end

  # TODO these parameter names are no good
  def card_count_for_player(number)
    player = player_number(number)
    player.card_count
  end

  def cards_for_player(number)
    player = player_number(number)
    player.hand
  end

  def books_for_player(number)
    player = player_number(number)
    player.books
  end

  # TODO seems odd that game draws for player
  # TODO these names stink
  def draw_card_for_player(number)
    player_number(number).add_card_to_hand(@deck.give_top_card)
  end
end
