Feature: Renew a space
  As Alice
  I want to renew my space rental
  So that I can continue organizing and naming assets easily.

  Background:
    Given renewing a space costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum space duration is one year
    And Alice has 10000000 xem in her account

  Scenario Outline: An account renews a space
    Given Alice owns the active space <name>
    When Alice renews the space named <name> for <seconds> seconds
    Then the space rental should be extended in <seconds> seconds
    And her xem balance should decrease in <cost> units

    Examples:
    | name      | seconds | cost |
    | alice     | 60      | 0.4  |

  Scenario Outline: An account renews a space with an invalid duration
    Given Alice owns the active space <name>
    When Alice renews the space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
    | name   | seconds  | error                                         |
    | test3  | 0        | Failure_Namespace_Eternal_After_Nemesis_Block |
    | test4  | -1       | Failure_Namespace_Invalid_Duration	          |
    | test5  | 1        | Failure_Namespace_Invalid_Duration            |
    | test6  | 47304000 | Failure_Namespace_Invalid_Duration            |

  Scenario Outline: An account rents a space which is already owned by another account
    Given Bob owns the active space <name>
    When Alice renews the space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name    | seconds |  error                           |
      | bob     | 60      | Failure_Namespace_Owner_Conflict |

  Scenario Outline: An account does not have enough funds
    Given Alice owns the active space <name>
    And   she has spent all her xem
    When  Alice rents a space named <name> for <seconds> seconds
    Then  she should receive the error "<error>"

    Examples:
      | name  |seconds | error                             |
      | alice | 15     | Failure_Core_Insufficient_Balance |
