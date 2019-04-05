Feature: Register a namespace
  As Alice
  I want to register a namespace
  So that I can organize and name assets easily.

  Background:
    Given registering a namespace costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum registration period is 1 year
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

  Scenario Outline: An account registers a namespace
    When Alice registers a namespace named <name> for <time> seconds
    Then she should receive a confirmation message
    And she should become the owner of the new namespace <name>
    And it should be registered for at least <time> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      | name  | time | cost |
      | test1 | 15   | 0.1  |
      | test1 | 20   | 0.2  |
      | test2 | 30   | 0.2  |

  Scenario Outline: An account tries to register a namespace with an invalid duration
    When Alice registers a namespace named "alice" for <time> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | time        | error                                         |
      | 0           | Failure_Namespace_Eternal_After_Nemesis_Block |
      | -1          | Failure_Namespace_Invalid_Duration            |
      | 40000000000 | Failure_Namespace_Invalid_Duration            |

  Scenario Outline: An account tries to register a namespace with an invalid name
    When Alice registers a namespace named "<name>" for 1 day
    Then she should receive the error "Failure_Namespace_Invalid_Name"
    And her xem balance should remain intact

    Examples:
      | name                                                              |
      | ?€!                                                               |
      | this_is_a_really_long_space_name_this_is_a_really_long_space_name |

  Scenario: An account tries to register a namespace with a reserved name
    When Alice registers a namespace named "xem" for 1 day
    Then she should receive the error "Failure_Namespace_Root_Name_Reserved"
    And her xem balance should remain intact

  Scenario: An account tries to register a namespace which is already registered by another account
    Given Bob registered the namespace "bob"
    And  the namespace is registered for a week
    When Alice registers a namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to register a namespace which is already registered by another account during the redemption period
    Given Bob registered the namespace "bob"
    And   the namespace is under redemption period
    When Alice registers a namespace named "bob" for 1 day
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to register a namespace but does not have enough funds
    Given Alice has spent all her xem
    When Alice registers a namespace named "alice" for 1 day
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  # Account filters
  Scenario: An account tries to register a namespace but has not allowed sending "REGISTER_NAMESPACE" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    When "Alice" registers the namespace named "alice" for 1 day
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to register a namespace but has blocked sending "REGISTER_NAMESPACE" transactions
    Given Alice blocked sending "REGISTER_NAMESPACE" transactions
    When "Alice" registers the namespace named "alice" for 1 day
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  # Status errors not treated:
  # - Failure_Namespace_Invalid_Namespace_Type
  # - Failure_Namespace_Name_Id_Mismatch
  # - Failure_Namespace_Id_Mismatch
  # - Failure_Namespace_Already_Active
  # - Failure_Namespace_Max_Children_Exceeded
