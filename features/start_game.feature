Feature: Start game
  In order to play GoFish
  As a potential player
  I want a game to start when there are enough players

  @javascript
  Scenario: Not enough players join a game in time
    Given I am waiting for a game with 2 players
    When no other player joins in time
    Then the game starts
    And I am playing one robot

  @javascript
  Scenario: Enough players
    Given I am waiting for a game with 2 players
    When another player joins the game
    Then the game starts
    And I am playing one opponent

  @javascript
  Scenario: Player joins with wrong number of opponents
    Given I am waiting for a game with 2 players
    When a player joins with the wrong number of opponents
    Then the match tells me to wait for opponents
