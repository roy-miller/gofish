Feature: Play game
  In order to play GoFish
  As a player
  I want to exchange cards with other players

  Background:
    Given a game with three players

  @javascript
  Scenario: I ask my first opponent for cards he has
    Given it is my turn
    When I ask my first opponent for cards he has
    Then I get the cards
    And it is still my turn

  @javascript
  Scenario: I ask my first opponent for cards he does not have
    Given it is my turn
    And I have a card my first opponent does not
    When I ask my first opponent for cards he does not have
    Then I go fishing
    And it becomes my first opponent's turn

  @javascript
  Scenario: I draw what I asked for
    Given it is my turn
    And I have the rank I'll draw
    When I ask my first opponent for the rank I'll draw
    Then I go fishing
    And it is still my turn

  @javascript
  Scenario: I do not draw what I asked for
    Given it is my turn
    And I have a card my first opponent does not
    And I don't have the rank I'll draw
    When I ask my first opponent for a rank I won't draw
    Then I go fishing
    And it becomes my first opponent's turn

  @javascript
  Scenario: My first opponent asks me for cards I have
    Given it is my first opponent's turn
    When my first opponent asks me for cards I have
    Then I give him the cards
    And it is still my first opponent's turn

  @javascript
  Scenario: My first opponent asks me for cards I do not have
    Given it is my first opponent's turn
    When my first oppponent asks me for cards I do not have
    Then I do not give him the cards
    And it is my second opponent's turn

  @javascript
  Scenario: Opponent asks another opponent for cards second opponent has
    Given it my first opponent's turn
    When my first opponent asks my second opponent for cards he has
    Then my first opponent gets the cards
    And it is my first opponent's turn

  @javascript
  Scenario: Opponent asks another opponent for cards second opponent does not have
    Given it my first opponent's turn
    When my first opponent asks my second opponent for cards he does not have
    Then my first opponent does not get the cards
    And it is my second opponent's turn
