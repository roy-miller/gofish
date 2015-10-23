require_relative './deck.rb'
require_relative './card.rb'

class Game
  attr_accessor :deck, :players, :winner, :loser

  def initialize
    @deck = Deck.new
    @players = []
    @winner
    @loser
  end

  def add_player(player)
    @players << player
  end

  def player1
    @players.first
  end

  def player2
    @players.last
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

  def play_round(cards_played = {player1: [], player2: []})
    if over?
      declare_game_winner
      return build_result(winner: @winner, loser: @loser, cards_played: cards_played)
    end

    build_result(winner: winner, loser: loser, cards_played: cards_played)
  end

  def build_result(winner:, loser:, cards_played:)
    RoundResult.new(winner: winner,
                    loser: loser,
                    cards_played: {
                      player1: cards_played[:player1],
                      player2: cards_played[:player2]
                    })
  end

  def declare_game_winner
    if player1.out_of_cards?
      @winner = player2
      @loser = player1
    end
    if player2.out_of_cards?
      @winner = player1
      @loser = player2
    end
    [@winner, @loser]
  end

  def over?
    player1.out_of_cards? || player2.out_of_cards?
  end
end
