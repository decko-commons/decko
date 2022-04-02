Feature: Reset password
  In order to be able to recover lost account access
  As an authorized user
  I want to be able to reset my password

  Background:
    # There is a user named Joe User in the test data with the email "joe@user.com"
    # Poor Joe has forgotten his password (which we know to be joe_pass)

  Scenario: Resetting password
    When I go to the homepage
    And I follow "Sign in"
    And I follow "Reset Password"
    And I enter "joe@user.com" into "*email" in modal
    And I press "Reset my password"
    And I wait 4 seconds
    Then "joe@user.com" should receive an email with subject "reset password for My Deck"

    When I open the email
    And I click the first link in the email
    Then I should see "Joe User"

    When I enter "joe_pass_reset" into "*password" in modal
    And I press "Save and Close"
    Then I should see "encrypted"

    When I go to the homepage
    And I follow "Sign out"
    Then I should not see "Joe User"

    When I follow "Sign in"
    And I enter "joe@user.com" into "*email"
    And I enter "joe_pass_reset" into "*password"
    And I press "Sign in"
    Then I should see "Joe User"
