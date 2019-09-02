Feature: Setting up
  In order to be able to start a new deck
  As a Decker
  I want to setup an initial account

  Background:

  Scenario: Decker visits site for first time
    Given site simulates setup need
#done here bc cache gets cleared otherwise

    When I go to the homepage
    Then I should see "Your deck is ready"

    When I fill in "card_name" with "The Newber"
    And I enter "newb@decko.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Set up"
    Then I should see "The Newber"

    When I go to card "The Newber+*roles"
    Then I should see "Administrator"

    When I follow "Sign out"
    And I follow "Sign in"
    And I enter "newb@decko.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Sign in"
    Then I should see "The Newber"

    And site stops simulating setup need

