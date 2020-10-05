@simulate-setup
Feature: Setting up
  In order to be able to start a new deck
  As a Shark
  I want to setup an initial account

  Background:

  Scenario: Shark visits site for first time
    When I go to the homepage
    Then I should see "Your deck is ready"

    When I fill in "card_name" with "The Newber"
    And I enter "newb@decko.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Set up"
    And I wait a sec
    Then I should see "The Newber"

    When I go to card "The Newber+*roles"
    Then I should see "Administrator"

    When I follow "Sign out"
    And I follow "Sign in"
    And I enter "newb@decko.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Sign in"
    Then I should see "The Newber"

