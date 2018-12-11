Feature: Rent a namespace
  As Alice
  I want to rent a namespace
  So that I can organize and name assets easily.

  Background:
    Given renting a namespace costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum namespace duration is 1 year
    And the namespace name can have up to 64 characters
    And the following namespace names are reserved
      | xem  |
      | nem  |
      | user |
      | org  |
      | com  |
      | biz  |
      | net  |
      | edu  |
      | mil  |
      | gov  |
      | info |
    And Alice has 10000000 xem in her account

  Scenario Outline: An account rents a namespace
    When Alice rents a namespace named <name> for <time> seconds
    Then she should become the owner of the new namespace <name>
    And it should be rented for <time> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      | name  | time  | cost |
      | test1 | 15    | 0.1  |
      | test1 | 25    | 0.2  |
      | test2 | 30    | 0.2  |

  Scenario Outline: An account tries to rent a namespace with an invalid duration
    When Alice rents a namespace named "alice" for <time> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | time     | error                                         |
      | 0        | Failure_Namespace_Eternal_After_Nemesis_Block |
      | -1       | Failure_Namespace_Invalid_Duration	           |
      | 3000000  | Failure_Namespace_Invalid_Duration            |

  Scenario Outline: An account tries to rent a namespace with an invalid name
    When Alice rents a namespace named <name> for 1 day
    Then she should receive the error "Failure_Namespace_Invalid_Name"
    And her xem balance should remain intact

    Examples:
      | name                                                               |
      | ?€!                                                                |
      | this_is_a_really_long_space_name_this_is_a_really_long_space_name  |

  Scenario: An account tries to rent a namespace with a reserved name
    When Alice rents a namespace named "xem" for 1 day
    Then she should receive the error "Failure_Namespace_Root_Name_Reserved"
    And her xem balance should remain intact

  Scenario: An account tries to rent a namespace which is already owned by another account
    Given Bob owns the active namespace "bob"
    When Alice rents a namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to rent a namespace but not have enough funds
    Given Alice has spent all her xem
    When Alice rents a namespace named "alice" for 1 day
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  # Todo: Failure_Namespace_Invalid_Namespace_Type