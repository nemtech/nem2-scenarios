Feature: Create a subnamespace
  As Alice
  I want to create a subnamespace
  So that I can organize and name assets.

  Background:
    Given creating a subnamespace costs 10 xem
    And the mean block generation time is 15 seconds
    And the maximum level of nested spaces is 3
    And the subnamespace name can have up to 64 characters
    And Alice has 10000000 xem in her account

  Scenario Outline: An account creates a subnamespace

    Given Alice owns an active namespace named "<parent-name>"
    When Alice creates a subnamespace named "<subnamespace-name>"
    Then she should become the owner of the new subnamespace "<subnamespace-name>"
    And her xem balance should decrease in 10 units
    And she should receive a confirmation message

    Examples:
      | parent-name   |  subnamespace-name |
      | one           | one.two        |
      | one.two       | one.two.three  |

  Scenario Outline: An account tries to create a subnamespace with an invalid name
    Given Alice owns an active namespace named "alice"
    When Alice creates a namespace named "<subnamespace-name>"
    Then she should receive the error "Failure_Namespace_Invalid_Name"
    And her xem balance should remain intact

    Examples:
      | subnamespace-name                                                                     |
      | alice.?€!                                                                             |
      | alice.this_is_a_really_long_subnamespace_name_this_is_a_really_long_subnamespace_name |

  Scenario: An account tries to create a subnamespace with a parent namespace owned by another account
    Given Bob owns the active namespace "bob"
    When Alice creates a subnamespace named "bob.subnamespace"
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace and exceeds the number of allowed nested levels
    Given Alice owns an active namespace named "one.two.three"
    When Alice creates a subnamespace named "one.two.three.four"
    Then she should receive the error "Failure_Namespace_Too_Deep"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace that already exists
    Given Alice owns an active namespace named "one.two"
    When Alice creates a subnamespace named "one.two"
    Then she should receive the error "Failure_Namespace_Already_Exists"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace with parent namespace expired
    Given Alice owns the expired namespace "alice"
    When Alice creates a subnamespace named "alice.subnamespace"
    Then she should receive the error "Failure_Namespace_Expired"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace with an unknown parent namespace
    When Alice creates a subnamespace named "unknown.subnamespace"
    Then she should receive the error "Failure_Namespace_Parent_Unknown"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace but does not have enough funds
    Given Alice owns the expired namespace "alice"
    And  she has spent all her xem
    When Alice creates a subnamespace named "alice.subnamespace"
    Then she should receive the error "Failure_Core_Insufficient_Balance"
