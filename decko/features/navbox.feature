@javascript
Feature: Navbox
  As a Casual site user
  I want to be able search for site content

  Scenario: quick search
    Given I go to the homepage
    When I enter "Joe" in the navbox
    Then I should see "Joe Camel"
    And I should see "JoeNow"
    Then I press enter to search
    Then I should see "Search results for: Joe"

  Scenario: wql search
    Given I go to the homepage
    When I enter '{"type":"User"}' in the navbox
    Then I press enter to search
    Then I should see "Search results"
    And I should see "Big Brother"

  Scenario: paging
    Given I go to the homepage
    When I enter "skin" in the navbox
    Then I should see "search: skin"
    Then I press enter to search
    Then I should see "Search results"
    And I should see "Sketchy skin"
    When I click on "2"
    Then I should see "lux skin"
