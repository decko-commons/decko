Feature: Presetting content
  In order to have an easy to use interface for creating cards
  As a Decker
  I want to be able to create links specifying content for plus cards of templated cards

  Scenario: User age
    Given I am signed in as Joe User
    And I go to new Book presetting name to "Harry Potter" and author to "JK Rowling"
    And I wait a sec
    And I press "Submit"
    And I wait for ajax response
    When I go to card "Harry Potter+author"
    Then I should see "JK Rowling"

