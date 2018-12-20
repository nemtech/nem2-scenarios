Feature: Extend an asset registration period
  As Alice
  I want to extend an asset registration period
  So that others can still hold and send the asset.

  Background:
    Given extending an asset registration period costs 50 xem per block
    And the mean block generation time is 15 seconds
    And the maximum registration period is 1 year
    And Alice has 10000000 xem in her account

  Scenario Outline: An account extends an asset registration period
    Given Alice registered an asset for a week
    When Alice extends the registration of the asset for <time> seconds
    Then she should receive a confirmation message
    And the asset registration period should be extended in at least <time> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      | time  | cost |
      | 15    | 50   |
      | 25    | 100  |
      | 30    | 100  |

  Scenario Outline: An account tries to extend an asset registration for an invalid period
    Given Alice registered an asset for a week
    When Alice extends the registration of the asset for <time> seconds
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | time        | error                           |
      | 0           | Failure_Mosaic_Invalid_Duration |
      | -1          | Failure_Mosaic_Invalid_Duration |
      | 40000000000 | Failure_Mosaic_Invalid_Duration |

  Scenario: An account tries to extend an asset registration period but another account registered it
    Given Bob registered an asset for a week
    When Alice extends the registration of the asset for 1 day
    Then she should receive the error "Failure_Mosaic_Owner_Conflict"
    And her xem balance should remain intact

  Scenario: An account tries to extend an the duration of a non-expirable asset
    Given Alice registered a non-expirable asset
    When Alice extends the registration of the asset for 1 day
    Then she should receive the error "Failure_Mosaic_Already_Non_Expirable"
    And her xem balance should remain intact
  # Todo: The error message is not implemented yet. It may change.

  Scenario: An account tries to extend an asset registration period but does not have enough funds
    Given Alice registered an asset for a week
    And  she has spent all her xem
    When Alice extends the registration of the asset for 1 day
    Then  she should receive the error "Failure_Core_Insufficient_Balance"
