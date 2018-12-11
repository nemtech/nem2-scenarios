Feature: Create a subspace
  As Alice
  I want to create a subspace
  So that I can organize and name assets.

  Background:
    Given creating a subspace costs 10 xem
    And the mean block generation time is 15 seconds
    And the maximum level of nested spaces is 3
    And the subspace name can have up to 64 characters
    And Alice has 10000000 xem in her account

  Scenario Outline: An account creates a subspace

    Given Alice owns an active space named <parent-name>
    When Alice creates a subspace named <subspace-name>
    Then she should become the owner of the new subspace <name>
    And her xem balance should decrease in 10 units

    Examples:
      | parent-name   |  subspace-name |
      | one           | one.two        |
      | one.two       | one.two.three  |

  Scenario Outline: An account tries to create a subspace with an invalid name
    Given Alice owns an active space named "alice"
    When Alice creates a space named <subspace-name>
    Then she should receive the error "Failure_Namespace_Invalid_Name"
    And her xem balance should remain intact

    Examples:
       | subspace-name                                                                 |
       | alice.?€!                                                                     |
       | alice.this_is_a_really_long_subspace_name_this_is_a_really_long_subspace_name |

  Scenario: An account tries to create a subspace with a parent space owned by another account
    Given Bob owns the active space "bob"
    When Alice creates a subspace named "bob.subspace"
    Then she should receive the error "Failure_Namespace_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to create a subspace and exceeds the number of allowed nested levels
    Given Alice owns an active space named "one.two.three"
    When Alice creates a subspace named "one.two.three.four"
    Then she should receive the error "Failure_Namespace_Too_Deep"
    And her xem balance should remain intact

  Scenario: An account tries to create a subspace that already exists
    Given Alice owns an active space named "one.two"
    When Alice creates a subspace named "one.two"
    Then she should receive the error "Failure_Namespace_Already_Exists"
    And her xem balance should remain intact

  Scenario: An account tries to create a subspace with parent space expired
    Given Alice owns the expired space "alice"
    When Alice creates a subspace named "alice.subspace"
    Then she should receive the error "Failure_Namespace_Expired"
    And her xem balance should remain intact

  Scenario: An account tries to create a subspace with an unknown parent space
    When Alice creates a subspace named "unknown.subspace"
    Then she should receive the error "Failure_Namespace_Parent_Unknown"
    And her xem balance should remain intact

  Scenario: An account tries to create a subspace but does not have enough funds
    Given Alice owns the expired space "alice"
    And  she has spent all her xem
    When Alice creates a subspace named "alice.subspace"
    Then she should receive the error "Failure_Core_Insufficient_Balance"
