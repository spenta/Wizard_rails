Feature: Form
  In order to fill in a form
  As a user
  I want to enter my choices
  
  Background:
    Given a set of usages and super usages

  @javascript
  Scenario: Select usages
    Given I am on the home page
    When I follow "link_to_form"
    And I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 2
    And I select usage 4
    And I select usage 5
    And I press validate
    Then only super usages 1, 2 should be validated
