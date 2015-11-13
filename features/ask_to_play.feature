Feature: Ask to play
  In order to play GoFish
  As a potential player
  I want to ask to play a number of opponents

  Scenario: First player asks to play
    Given I am on the welcome page
    When I choose my game options and play
    Then my player page tells me to wait for opponents

  Scenario: Enough players to play
    Given I ask to play
    And there are enough players for a game
    Then my player page shows the start of the game

  #Scenario: Check this
  #  Given check this
