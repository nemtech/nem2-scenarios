Feature: Register an asset
  As Alice
  I want to register an asset
  So that I can send one unit to Bob.

  Background:
    Given the native currency asset is "cat.currency"
    And registering an asset costs 500 "cat.currency"
    And the mean block generation time is 15 seconds
    And the maximum asset registration period is 10 years
    And the maximum asset divisibility is 6
    And the maximum number of assets an account can have is 1000
    And the maximum asset supply is 9000000000000000
    And Alice has 10000000 "cat.currency" in her account

  @bvt
  Scenario Outline: An account registers an expiring asset with valid properties with divisibility
    When Alice registers <transferability>, supply <supply-mutability> with divisibility <divisibility> asset for <duration> in blocks
    Then Alice should become the owner of the new asset for at least <duration> blocks
    And Alice "cat.currency" balance should decrease in 500 units

    Examples:
      | duration | transferability    | supply-mutability | divisibility |
      | 1        | transferable       | immutable         | 0            |
      | 2        | nontransferable    | mutable           | 6            |
      | 3        | transferable       | mutable           | 1            |
      | 1        | nontransferable    | immutable         | 2            |

  @bvt
  Scenario: An account registers a non-expiring asset
    When Alice registers a non-expiring asset
    And Alice should become the owner of the new asset
    And Alice "cat.currency" balance should decrease in 500 units

  Scenario Outline: An account tries to register an asset with invalid values
    When Alice registers an asset for <duration> in blocks with <divisibility> divisibility
    Then she should receive the error "<error>"
    And Alice "cat.currency" balance should remain intact

    Examples:
      | duration | divisibility | error                                |
      | 0        | 0            | Failure_Mosaic_Invalid_Duration      |
      | 1        | -1           | Failure_Mosaic_Invalid_Divisibility  |
      | 22000000 | 0            | Failure_Mosaic_Invalid_Duration      |
      | 60       | 7            | Failure_Mosaic_Invalid_Divisibility  |

  Scenario: An account tries to register an asset but does not have enough funds
    Given Sue has spent all her "cat.currency"
    When Sue registers an asset
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  @not-implemented
  Scenario: An account tries to register an asset but already owns 999 different assets
    Given Alice is the owner of 999 assets
    When Alice registers an asset for 1 day
    Then she should receive the error "Failure_Mosaic_Max_Mosaics_Exceeded"
    And her "cat.currency" balance should remain intact

  # Account Restrictions
  @not-implemented
  Scenario: An account tries to register an asset but has not allowed sending "MOSAIC_DEFINITION" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    When Alice registers an asset for 2 seconds
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"

  @not-implemented
  Scenario: An account tries to register an asset but has blocked sending "MOSAIC_DEFINITION" transactions
    Given Alice blocked sending "MOSAIC_DEFINITION" transactions
    When Alice registers an asset for 2 seconds
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"
