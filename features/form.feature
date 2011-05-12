Feature: Form
  In order to fill in a form
  As a user
  I want to enter my choices
  
  Background:
    Given a set of usages and super usages
    And I am on the home page
    And I follow "link_to_form"

  @current
  @javascript
  Scenario: Select no usage
    When I click on next
    Then I should see the "no usage selected error" error

  @javascript
  Scenario: Select usages
    When I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 2
    And I select usage 4
    And I select usage 5
    And I press validate
    Then only super usages 1, 2 should be selected

  @javascript
  Scenario: Select then cancel usages
    When I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 1
    And I press not interested
    And I press validate
    Then no super usages should be selected

  @javascript
  Scenario: Select usages and go to next step
    When I select super usage 1
    And I select usage 1
    And I press validate
    And I select super usage 2
    And I select usage 4
    And I select usage 5
    And I press validate
    And I click on next
    Then I should be on the weights step
    And I can change weight only for super usages 1, 2
    And weight for super usage 1 should be 50
    And weight for super usage 2 should be 50
