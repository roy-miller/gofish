Feature: Start game
  In order to play GoFish
  As a potential player
  I want a game to start when there are enough players

  @javascript
  Scenario: Not enough players
    When I choose my game options and play
    Then my player page tells me to wait for opponents

  @javascript
  Scenario: Enough players
    Given I am waiting for a game with 2 players
    When another player joins the game
    Then my player page shows the start of the game
