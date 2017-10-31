@javascript
Feature: Reference
  In order to connect related cards
  As a Decker

  Background:
    Given I am signed in as Joe Admin

  Scenario: Renaming a embed card
    When I create PlainText card "Vignesh" with content "Indian"
    And I wait for ajax response
    And I create PlainText card "Kawaii Man" with content "[[Vignesh]]"
    And I wait for ajax response
    Then I should see "Vignesh"
    And I wait for ajax response
    And I go to rename "Vignesh"
    And I fill in "card_name" with "Srivigneshwar"
    And I press "Rename"
    And I wait 2 seconds
    And I press "Rename and Update"
    And I wait 2 seconds
    Then I go to card "Kawaii Man"
    And I should see "Srivigneshwar"



