Feature: Form
  In order to fill in a form
  As a user
  I want to enter my choices
  
  Background:
    Given a set of usages and super usages
    And I am on the home page
    And I follow "link_to_form"

  @javascript
  Scenario: Select usages
    When I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 2
    And I select usage 4
    And I select usage 5
    And I press validate
    Then only super usages 1, 2 should be validated

  @current
  @javascript
  Scenario: Select then cancel usages
    When I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 1
    And I press not interested
    And I press validate
    Then no super usages should be selected
