Feature: Register an asset
  As Alice
  I want to register an asset
  So that I can send one unit to Bob.

  Background:
    Given registering an expiring asset costs 50 xem per block
    And registering a non-expiring asset costs 5000 xem
    And the mean block generation time is 15 seconds
    And the maximum registration period is 1 year
    And the maximum asset divisibility is 6
    And the maximum asset supply is 9000000000
    And Alice has 10000000 xem in her account

  Scenario Outline: An account registers an expiring asset
    When Alice registers an asset for <seconds> seconds
    Then she should receive a confirmation message
    And she should become the owner of the new asset
    And it should be registered for at least <seconds> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      |seconds| cost |
      | 15    | 50   |
      | 20    | 100  |
      | 30    | 100  |

  Scenario: An account registers a non-expiring asset
    When Alice registers a non-expiring asset
    Then she should receive a confirmation message
    And she should become the owner of the non-expiring asset
    And her xem balance should decrease in 5000 xem

  Scenario Outline: An account tries to register an asset for an invalid duration
    When Alice registers an asset for <seconds> seconds
    Then she should receive the error "Failure_Mosaic_Invalid_Duration"
    And her xem balance should remain intact

    Examples:
      | seconds    |
      | 0          |
      | -1         |
      | 1          |
      | 40000000000|

  Scenario Outline: An account tries to register an asset with a valid initial supply
    When Alice registers an asset with an initial supply of <supply> for 1 day
    Then she should receive a confirmation message
    And she should become the owner of the new asset
    And it should have a supply of <supply>

    Examples:
      |supply      |
      | 1          |
      | 9000000000 |

  Scenario Outline: An account tries to register an asset with an invalid initial supply
    When Alice registers an asset with an initial supply of <supply> for 1 day
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | supply     | error                                       |
      | -1         | Failure_Mosaic_Supply_Negative              |
      | 0          | Failure_Mosaic_Invalid_Supply_Change_Amount |
      | 9000000001 | Failure_Mosaic_Supply_Exceeded              |

  Scenario Outline: An account registers an asset with a valid property
    When Alice registers a "<property>" asset for 1 day
    Then she should receive a confirmation message
    And she should become the owner of the new asset
    And it should have the property "<property>"

    Examples:
      | property         |
      | transferable     |
      | non-transferable |
      | supply mutable   |
      | supply immutable |
      | levy mutable     |
      | levy immutable   |

  Scenario: An account tries to register an asset with an invented property
    When Alice registers a "squared" asset for 1 day
    Then she should receive the error "Failure_Mosaic_Invalid_Property"
    And her xem balance should remain intact

  Scenario Outline: An account tries to register an asset with a valid divisibility
    When Alice registers an asset with divisibility <divisibility> for 1 day
    Then she should receive a confirmation message
    And she should become the owner of the new asset
    And the asset should handle up to <divisibility> decimals

    Examples:
      | divisibility |
      | 0            |
      | 6            |

  Scenario Outline: An account tries to register an asset with an invalid divisibility
    When Alice registers an asset with divisibility <number> for 1 day
    Then she should receive the error "Failure_Mosaic_Invalid_Property"
    And her xem balance should remain intact

    Examples:
      | number |
      | -1     |
      | 7      |

  Scenario: An account tries to register an asset but does not have enough funds
    Given Alice has spent all her xem
    When Alice registers an asset for 1 day
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  # Todo: Failure_Mosaic_Invalid_Flags
