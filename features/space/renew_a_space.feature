Feature: Renew a space
  As Alice
  I want to renew my space rental
  So that I can continue organizing and naming assets.

  Background:
    Given renewing a space costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum space duration is 1 year
    And Alice has 10000000 xem in her account

  Scenario: An account renews a space
    Given Alice owns the active space "alice"
    When Alice renews the space named "alice" for 15 seconds
    Then the space rental should be extended in 15 seconds
    And her xem balance should decrease in 0.1 units

  Scenario Outline: An account tries to renew a space with an invalid duration
    Given Alice owns the active space "alice"
    When Alice renews the space named "alice" for <time> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | time    | error                                          |
      | 0       | Failure_Namespace_Eternal_After_Nemesis_Block  |
      | -1      | Failure_Namespace_Invalid_Duration             |
      | 3000000 | Failure_Namespace_Invalid_Duration             |

  Scenario: An account tries to renew a space which is already owned by another account
    Given Bob owns the active space "bob"
    When Alice renews the space named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to renew a space but does not have enough funds
    Given Alice owns the active space "alice"
    And   she has spent all her xem
    When  Alice renews the space named "alice" for 1 day
    Then  she should receive the error "Failure_Core_Insufficient_Balance"