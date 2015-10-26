require_relative './deck.rb'
require_relative './card.rb'
require_relative './player.rb'
require_relative './request.rb'

class Game
  attr_accessor :deck, :players, :winner, :loser

  def initialize(players=[])
    @deck = Deck.new
    @players = players
    @winner
  end

  def add_player(player)
    @players << player
  end

  def deal(cards_per_player:)
    @deck.shuffle
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

  def player_for_name(name)
    @players.select { |player| player.name == name }.first
  end

  def ask_player_for_cards(request)
    player = player_for_name(request.recipient.name)
    response = player.receive_request(request)
    response
  end

  def give_cards_to_player(name, response)
    player = player_for_name(name)
    player.receive_response(response)
  end

  def card_count_for_player_named(name)
    player = player_for_name(name)
    player.cards.count
  end

  def cards_for_player_named(name)
    player = player_for_name(name)
    player.cards
  end

  def books_for_player_named(name)
    player = player_for_name(name)
    player.full_books
  end

  def draw_card(name)
    player_for_name(name).add_card_to_hand(@deck.give_top_card)
  end
end
