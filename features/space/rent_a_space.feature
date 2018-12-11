Feature: Rent a space
  As Alice
  I want to rent a space
  So that I can organize and name assets easily.

  Background:
    Given renting a space costs 0.1 xem per block
    And the mean block generation time is 15 seconds
    And the maximum space duration is one year
    And the space name can have up to 64 characters
    And the following space names are reserved
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

  Scenario Outline: An account rents a space
    When Alice rents a space named <name> for <seconds> seconds
    Then she should become the owner of the new space <name>
    And it should be rented for <seconds> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      | name  | seconds | cost |
      | test1 | 60      | 0.4  |
      | test2 | 120     | 0.8  |

  Scenario Outline: An account tries to rent a space with an invalid duration
    When Alice rents a space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name   | seconds  | error                                         |
      | test3  | 0        | Failure_Namespace_Eternal_After_Nemesis_Block |
      | test4  | -1       | Failure_Namespace_Invalid_Duration	            |
      | test5  | 1        | Failure_Namespace_Invalid_Duration            |
      | test6  | 47304000 | Failure_Namespace_Invalid_Duration            |

  Scenario Outline: An account tries to rent a space with an invalid name
    When Alice rents a space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name                                                               | seconds |  error                         |
      | ?€!                                                                | 60      | Failure_Namespace_Invalid_Name |
      | this_is_a_really_long_space_name_this_is_a_really_long_space_name  | 60      | Failure_Namespace_Invalid_Name |

  Scenario Outline: An account tries to rent a space with a reserved name
    When Alice rents a space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name    | seconds |  error                               |
      | xem     | 60      | Failure_Namespace_Root_Name_Reserved |
      | gov     | 60      | Failure_Namespace_Root_Name_Reserved |

  Scenario Outline: An account tries to rent a space which is already owned by another account
    Given Bob owns the active space <name>
    When Alice rents a space named <name> for <seconds> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | name    | seconds |  error                           |
      | bob     | 60      | Failure_Namespace_Owner_Conflict |


  Scenario Outline: An account tries to rent a space but not have enough funds
    Given Alice has spent all her xem
    When Alice rents a space named <name> for <seconds> seconds
    Then she should receive the error "<error>"

    Examples:
      | name  |seconds | error                             |
      | alice | 15     | Failure_Core_Insufficient_Balance |

  # Todo: Failure_Namespace_Invalid_Namespace_Type