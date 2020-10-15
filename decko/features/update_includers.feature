@javascript @delayed-jobs
Feature: Updates for Children of watched cards
  In order to keep track of changes that are important to me
  As an Editor
  I want to be notified when someone changes a child of a card I'm watching

  #should this be in watch?

  Background:
    Given I am signed in as Joe User
    And I create Book card "Ulysses"
    And Joe Camel is watching "Ulysses+*self"
    And Joe Admin is watching "Book+*type"

  Scenario: Watcher should be notified of updates to included plus card
    When I create card "Ulysses+Author" with content "James Joyce"
    And I wait for ajax response
    #And He should see "added Ulysses+Author" in the email  -- FIXME need multiline matching
    Then Joe Admin should be notified that "Joe User created \"Ulysses\+Author\""
    And Joe Camel should be notified that "Joe User created \"Ulysses\+Author\""
    When Joe Admin edits "Ulysses+Author" setting content to "Jim"
    Then Joe Camel should be notified that "Joe Admin updated \"Ulysses\+Author\""
    #And Joe Admin should be notified that "Joe User updated \"Ulysses\""

  Scenario: Should not notify of included but not plussed card
    When I create card "illustrator" with content "Picasso"
    Then No notification should be sent

  Scenario: Should not notify of plussed but not included card
    When I create card "Ulysses+random" with content "boo"
    Then No notification should be sent

  Scenario: Templated cards should only send one email when added or updated
    When I create Book card "Bros Krmzv" with plusses:
      |author|illustrator|
      |Dostoyevsky|Manet|
    Then Joe Admin should be notified that "Joe User created \"Bros Krmzv\""
    When I edit "Bros Krmzv" with plusses:
      |Author|illustrator|
      |Rumi|Monet|
    Then Joe Admin should be notified that "Joe User updated \"Bros Krmzv\""

  Scenario: Watching a plus card on multiedit; and watching both plus card and including card on multiedit
    Given I am signed in as Joe Admin
    And I create Cardtype card "Froot"
    And I create PlainText card "Froot+*type+*structure" with content "{{+colors}} {{+flavor}}"
    And I am signed in as Joe User
    And I create Froot card "Banana" with plusses:
      |colors|flavor|
      |yellow|sweet|
    And Joe Camel is watching "Banana+color+*self"
    When I edit "Banana" with plusses:
      |colors|flavor|
      |spotted|mushy|
    And I wait 1 second
    Then Joe Camel should be notified that "Joe User updated \"Banana\""
    When Joe Camel is watching "Banana+*self"
    And I wait a sec
    And I edit "Banana" with plusses:
      |colors|flavor|
      |green|mushy|
    And I wait 1 second
    Then Joe Camel should be notified that "Joe User updated \"Banana\""
    Given a clear email queue
    And I edit "Banana" with plusses:
      |colors|flavor|
      |green|mushy|
    Then No notification should be sent

  Scenario: Watching a plus card & including card on regular edit
    When I create card "Ulysses+Author" with content "Joyce"
    Then Joe Camel should be notified that "Joe User created \"Ulysses\+Author\""
    When Joe Camel is watching "Ulysses+Author+*self"
    And I edit "Ulysses+Author" setting content to "Jim"
    Then Joe Camel should be notified that "Joe User updated \"Ulysses\+Author\""
