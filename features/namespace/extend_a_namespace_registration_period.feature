Feature: Extend a namespace registration period
  As Alice
  I want to extend the namespace registration
  So that I can continue organizing and naming assets.

  Background:
    Given the native currency asset is "cat.currency"
    And extending a namespace registration period costs 1 "cat.currency" per block
    And the mean block generation time is 15 seconds
    And the maximum registration period is 1 year
    And Alice has 10000000 "cat.currency" in her account
    And the redemption period of a namespace is 1 day

  Scenario Outline: An account extends a namespace registration period
    Given "Alice" registered the namespace "alice" for a week
    When Alice extends the registration of the namespace named "alice" for <time> seconds
    Then she should receive a confirmation message
    And the namespace registration period should be extended for at least <time> seconds
    And her "cat.currency" balance should decrease in <cost> units

    Examples:
      | time | cost |
      | 15   | 1    |
      | 20   | 2    |
      | 30   | 2    |

  Scenario Outline: An account tries to extend a namespace registration for an invalid period
    Given "Alice" registered the namespace "alice" for a week
    When Alice extends the registration of the namespace named "alice" for <time> seconds
    Then she should receive the error "<error>"
    And her "cat.currency" balance should remain intact

    Examples:
      | time        | error                              |
      | 0           | Failure_Namespace_Invalid_Duration |
      | -1          | Failure_Namespace_Invalid_Duration |
      | 40000000000 | Failure_Namespace_Invalid_Duration |

  Scenario: An account tries to extend a namespace registration period but another account registered it
    Given "Bob" registered the namespace "bob" for a week
    When Alice extends the registration of the namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her "cat.currency" balance should remain intact

  Scenario: An account tries to extend a namespace registration period and this is under redemption period
    Given "Alice" registered the namespace "alice" for a week
    And   the namespace is now under redemption period
    When Alice extends the registration of the namespace named "alice" for 1 day
    Then she should receive a confirmation message
    And the namespace registration period should be extended for at least 1 day
    And her "cat.currency" balance should decrease in 5760 units

  Scenario: An account tries to extend a namespace registration period, this is under redemption but the account didn't created it
    Given "Bob" registered the namespace "bob" for a week
    And   the namespace is now under redemption period
    When Alice extends the registration of the namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her "cat.currency" balance should remain intact

  Scenario: An account tries to extend a namespace registration period but does not have enough funds
    Given "Alice" registered the namespace "alice" for a week
    And   she has spent all her "cat.currency"
    When  Alice extends the registration of the namespace named "alice" for 1 day
    Then  she should receive the error "Failure_Core_Insufficient_Balance"
