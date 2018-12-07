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
    And her xem balance should decrease in <cost> units

    Examples:
      | name   |  subspace-name       | cost |
      | one    | one.two              | 10   |
      | one.two| one.two.three        | 10   |

  Scenario Outline: An account creates a subspace with an invalid name
    Given Bob owns the active space <parent-name>
    When Alice creates a space named <subspace-name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | parent-name | subspace-name                                                             | error                         |
      | valid1      | valid1.?€!                                                                | Failure_Namespace_Invalid_Name |
      | valid2      | valid2.this_is_a_really_long_space_name_this_is_a_really_long_space_name  | Failure_Namespace_Invalid_Name |

  Scenario Outline: An account creates a subspace with a parent space owned by another account
    Given Bob owns the active space <parent-name>
    When Alice creates a subspace named <subspace-name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | parent-name  | subspace-name   | error                            |
      | bob          | bob.subspace    | Failure_Namespace_Owner_Conflict |


  Scenario Outline: An account creates a subspace and exceeds the number of allowed nested levels
    Given Alice owns an active space named <parent-name>
    When Alice creates a subspace named <subspace-name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | parent-name     | subspace-name      | error                          |
      | one.two.three   | one.two.three.four |   Failure_Namespace_Too_Deep   |

  Scenario Outline: An account creates a subspace that already exists
    Given Alice owns an active space named <parent-name>
    When Alice creates a subspace named <subspace-name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | parent-name | subspace-name      | error                            |
      | one.two     | one.two            | Failure_Namespace_Already_Exists |

  Scenario Outline: An account creates a subspace with parent space expired
    Given Alice owns the expired space <parent-name>
    When Alice creates a subspace named <subspace-name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | parent-name  | subspace-name   | error                     |
      | alice        | alice.subspace  | Failure_Namespace_Expired |

  Scenario Outline: An account creates a subspace with an unknown parent space
    When Alice creates a subspace named <name>
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name                | error                         |
      | unknown.subspace | Failure_Namespace_Parent_Unknown |


  Scenario Outline: An account does not have enough funds
    Given Alice owns the expired space <parent-name>
    And  she has spent all her xem
    When Alice rents a space named <subspace-name> for <seconds> seconds
    Then she should receive the error "<error>"

    Examples:
      | parent-name  | subspace-name  | seconds | error                             |
      | alice        | alice.subspace |  15     | Failure_Core_Insufficient_Balance |
