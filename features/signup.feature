Feature: Signup
  In order to signup
  As a new user
  I want to enter a user name and a password

  Background:
    Given there is no user
    And I am on the signup page

  Scenario: Create a new user
    When I fill the name field with "spenta"
    And I fill the password field with "pass"
    Then there should be a user named spenta
    And I should be on the home page
    And I should see "admin"
