Feature: Start game
  In order to play GoFish
  As a potential player
  I want a game to start when there are enough players

  @javascript
  Scenario: Not enough players
    When I choose my game options and play
    Then the match tells me to wait for opponents

  @javascript
  Scenario: Enough players
    Given I am waiting for a game with 2 players
    When another player joins the game
    Then I see the start of the game

  @javascript
  Scenario: Player joins with wrong number of opponents
    Given I am waiting for a game with 2 players
    When a player joins with the wrong number of opponents
    Then the match tells me to wait for opponents
