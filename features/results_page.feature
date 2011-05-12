Feature: Results page
  In order to navigate away from the result page
  As a user
  I want to click on the links on the page

  Background:
    Given a set of usages and super usages
    And a set of products
    And I am on the home page
    And I follow "link_to_form"
    And I select super usage 1
    And I select usage 1
    And I press validate
    And I click on next
    And I click on next
    And I click on next
   
  @javascript
  Scenario: Go back to previous page
    When I click on back
    Then I should be on the mobilities step

  @javascript
  Scenario: Start a new request
    When I click on restart
    Then I should be on the selection step
    And no super usages should be selected
