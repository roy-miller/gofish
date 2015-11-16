Feature: End game
  In order to end a game of GoFish
  As a player
  I want the game to end whenever the deck runs of out cards

  Background:
    Given a game with three players
    And a deck with one card left

  @javascript
  Scenario: I go fish, deck runs out of cards, game ends
    Given it is my turn
    And I have a card my first opponent does not
    When I ask my first opponent for cards he does not have
    Then I go fishing
    And the match tells me the game is over

  @javascript
  Scenario: An opponent goes fish, deck runs out of cards, game ends
    Given it is my first opponent's turn
    When my first oppponent asks me for cards I do not have
    Then my first opponent goes fishing
    And the match tells me the game is over
