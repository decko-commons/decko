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

  Scenario: cql search
    Given I go to the homepage
    When I enter '{"type":"User"}' in the navbox
    Then I should see "User"
    Then I press enter to search
    Then I should see "Search results"
    And I should see "Sample User"

  Scenario: paging
    Given I go to the homepage
    When I enter "skin" in the navbox
    Then I should see in search "search: skin"
    Then I press enter to search
    Then I should see "Search results"
    And I should see "Sample Skin"
    When I click on "2"
    Then I should see "minty skin"
