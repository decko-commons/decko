Feature: homepage

  I want to open the homepage

  @focus
  Scenario: Opening the homepage
    Given I open homepage
    Then I see "Welcome, Card Shark"
