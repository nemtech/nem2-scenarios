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

  Scenario: An account creates a subnamespace

    Given Alice registered the namespace "one" for a week
    When Alice creates a subnamespace named "one.two"
    Then she should receive a confirmation message
    And she should become the owner of the new subnamespace "one.two"
    And her xem balance should decrease in 10 units

  Scenario Outline: An account tries to create a subnamespace with an invalid name
    Given Alice registered the namespace "alice" for a week
    When Alice creates a namespace named "<subnamespace-name>"
    Then she should receive the error "Failure_Namespace_Invalid_Name"
    And her xem balance should remain intact

    Examples:
      | subnamespace-name                                                                     |
      | alice.?€!                                                                             |
      | alice.this_is_a_really_long_subnamespace_name_this_is_a_really_long_subnamespace_name |

  Scenario: An account tries to create a subnamespace with a parent namespace registered by another account
    Given Bob registered the namespace "bob" for a week
    When Alice creates a subnamespace named "bob.subnamespace"
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace and exceeds the number of allowed nested levels
    Given Alice registered the namespace "one" for a week
    And  she created the subnamespace "one.two.three"
    When Alice creates a subnamespace named "one.two.three.four"
    Then she should receive the error "Failure_Namespace_Too_Deep"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace that already exists
    Given Alice registered the namespace "one" for a week
    And  she created the subnamespace "one.two"
    When Alice creates a subnamespace named "one.two"
    Then she should receive the error "Failure_Namespace_Already_Exists"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace with parent namespace expired
    Given Alice registered the expired namespace "alice"
    When Alice creates a subnamespace named "alice.subnamespace"
    Then she should receive the error "Failure_Namespace_Expired"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace with an unknown parent namespace
    When Alice creates a subnamespace named "unknown.subnamespace"
    Then she should receive the error "Failure_Namespace_Parent_Unknown"
    And her xem balance should remain intact

  Scenario: An account tries to exceed the maximum number of subnamespaces
    Given Alice registered the namespace "alice" for one week
    And Alice created 500 subnamespaces under "alice" namespace
    When Alice creates a subnamespace named "one.501"
    Then she should receive the error "Failure_Namespace_Max_Children_Exceeded"
    And her xem balance should remain intact

  Scenario: An account tries to create a subnamespace but does not have enough funds
    Given Alice registered the namespace "one" for a week
    And  she has spent all her xem
    When Alice creates a subnamespace named "alice.subnamespace"
    Then she should receive the error "Failure_Core_Insufficient_Balance"
