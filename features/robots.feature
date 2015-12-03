Feature: Robots
  In order to play GoFish
  As a player
  I want to play a game with robots so I don't wait forever for other players

  @javascript
  Scenario: I ask my first robot opponent for cards he has
    Given a game with one real player and one robot
    And it is my turn
    When I ask my first opponent for cards he has
    Then I get the cards
    And it is still my turn

  @javascript
  Scenario: I ask my first robot opponent for cards he does not have
    Given a game with one real player and one robot
    And the robot thinks slowly
    And it is my turn
    And I have a card my first opponent does not
    When I ask my first opponent for cards he does not have
    Then I go fishing
    And it becomes my first opponent's turn

  @javascript
  Scenario: Robot opponent plays on his own
    Given a game with one real player and one robot
    When the match tells the robot to play
    Then my first opponent asks me for cards

  @javascript
  Scenario: Robot opponent asks another robot opponent for cards second one has
    Given a game with one real player and two robots
    And it is my first robot opponent's turn
    When my first opponent asks my second opponent for cards he has
    Then the match tells me my first opponent asked second opponent for cards
