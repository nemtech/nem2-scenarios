Feature: Extend a namespace registration period
  As Alice
  I want to extend the namespace registration
  So that I can continue organizing and naming assets.

  Background:
    Given extending a namespace registration period costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum registration period is 1 year
    And Alice has 10000000 xem in her account
    And the redemption period of a namespace is 1 day

  Scenario Outline: An account extends a namespace registration period
    Given Alice registered the namespace "alice"
    And  the namespace is registered for a week
    When Alice extends the registration of the namespace named "alice" for <time> seconds
    Then the namespace registration period should be extended for at least <time> seconds
    And her xem balance should decrease in <cost> units
    And she should receive a confirmation message

    Examples:
      | time  | cost |
      | 15    | 0.1  |
      | 20    | 0.2  |
      | 30    | 0.2  |

  Scenario Outline: An account tries to extend a namespace registration for an invalid period
    Given Alice registered the namespace "alice"
    And  the namespace is registered for a week
    When Alice extends the registration of the namespace named "alice" for <time> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | time        | error                              |
      | 0           | Failure_Namespace_Invalid_Duration |
      | -1          | Failure_Namespace_Invalid_Duration |
      | 40000000000 | Failure_Namespace_Invalid_Duration |

  Scenario: An account tries to extend a namespace registration period but another account registered it
    Given Bob registered the namespace "bob"
    And  the namespace is registered for a week
    When Alice extends the registration of the namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to extend a namespace registration period and this is under redemption period
    Given Alice registered the namespace "alice"
    And   the namespace is under redemption period
    When Alice extends the registration of the namespace named "alice" for 1 day
    Then the namespace registration period should be extended for at least 1 day
    And her xem balance should decrease in 576 units
    And she should receive a confirmation message

  Scenario: An account tries to extend a namespace registration period, this is under redemption but the account didn't created it
    Given Bob registered the namespace "bob"
    And   the namespace is under redemption period
    When Alice extends the registration of the namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to extend a namespace registration period but does not have enough funds
    Given Alice registered the namespace "alice"
    And   she has spent all her xem
    When  Alice extends the registration of the namespace named "alice" for 1 day
    Then  she should receive the error "Failure_Core_Insufficient_Balance"
