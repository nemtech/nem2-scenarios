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
    And the grace period of a namespace is 1 day

  @bvt
  Scenario Outline: An account extends a namespace registration period
    Given Alice registered the namespace named "alice" for 10 blocks
    When Alice extends the registration of the namespace named "alice" for <duration> blocks
    Then she should receive a confirmation message
    And the namespace registration period should be extended for at least <duration> blocks
    And her "cat.currency" balance should decrease in <cost> units

    Examples:
      | duration | cost |
      | 10       | 10   |
      | 20        | 20   |

  Scenario: An account tries to extend a namespace registration period and this is under grace period
    Given Alice registered the namespace named "aliceexp" for 6 block
    And   the namespace is now under grace period
    When Alice extends the registration of the namespace named "aliceexp" for 6 block
    Then she should receive a confirmation message
    And the namespace registration period should be extended for at least 6 blocks
    And her "cat.currency" balance should decrease in 6 units

  Scenario: An account tries to extend a namespace registration period but the account didn't created it
    Given Bob registered the namespace named "bobnew" for 5 block
    And the namespace is now under grace period
    When Alice tries to extends the registration of the namespace named "bobnew" for 6 block
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her "cat.currency" balance should remain intact

  Scenario: An account tries to extend a namespace registration period but does not have enough funds
    Given Bob registered the namespace named "bob" for 6 block
    When  Bob tries to extends the registration of the namespace named "bob" for 1000 blocks
    Then  she should receive the error "Failure_Core_Insufficient_Balance"

  @not-implemented
  Scenario Outline: An account tries to extend a namespace registration for an invalid period
    Given "Alice" registered the namespace "alice" for a week
    When Alice extends the registration of the namespace named "alice" for <duration> blocks
    Then she should receive the error "<error>"
    And her "cat.currency" balance should remain intact

    Examples:
      | duration        | error                              |
      | 0           | Failure_Namespace_Invalid_Duration |
      | -1          | Failure_Namespace_Invalid_Duration |
      | 2 years     | Failure_Namespace_Invalid_Duration |

  @not-implemented
  Scenario: Created subnamespaces and links are pruned after the grace period ends
    Given "Alice" registered the namespace "alice" for a week
    And   the namespace expires
    When  the grace period ends
    Then  "alice" links should be deleted
    And   "alice" subnamespaces should be deleted
    And "Bob" can register the namespace "alice" for a week
