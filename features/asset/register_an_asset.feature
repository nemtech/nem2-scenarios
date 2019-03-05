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
    And the maximum number of assets an account can have is 1000
    And the maximum asset supply is 9000000000
    And Alice has 10000000 xem in her account

  Scenario Outline: An account registers an expiring asset
    When Alice registers an asset for <seconds> seconds
    Then she should receive a confirmation message
    And she should become the owner of the new asset
    And it should be registered for at least <seconds> seconds
    And her xem balance should decrease in <cost> units

    Examples:
      | seconds | cost |
      | 15      | 50   |
      | 20      | 100  |
      | 30      | 100  |

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
      | seconds     |
      | 0           |
      | -1          |
      | 1           |
      | 40000000000 |

  Scenario: An account tries to register an asset but already owns 999 different assets
    Given Alice is the owner of 999 assets
    When Alice registers an asset for 1 day
    Then she should receive the error "Failure_Mosaic_Max_Mosaics_Exceeded"
    And her xem balance should remain intact

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
    Then she should receive the error "Failure_Mosaic_Invalid_Divisibility"
    And her xem balance should remain intact

    Examples:
      | number |
      | -1     |
      | 7      |

  Scenario: An account tries to register an asset but does not have enough funds
    Given Alice has spent all her xem
    When Alice registers an asset for 1 day
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  Scenario: An account tries to register an asset but has not allowed sending "MOSAIC_DEFINITION" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    When Alice registers an asset for 2 seconds
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to register an asset but has blocked sending "MOSAIC_DEFINITION" transactions
    Given Alice blocked sending "MOSAIC_DEFINITION" transactions
    When Alice registers an asset for 2 seconds
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: Alice wants to get her XEM balance after registering an expiring asset
    Given Alice registered an expiring asset for <seconds> seconds
    And she became the owner of the new expiring asset
    When Alice wants to get her xem balance after asset registration
    Then Alice should find her xem balance has decreased in <cost> units

  Scenario: Alice wants to get her XEM balance after registering a non-expiring asset
    Given Alice registered a non-expiring asset
    And she becomes the owner of the new non-expiring asset
    When Alice wants to get her xem balance after non-expiring asset registration
    Then Alice should find her xem balance decrease by 5000 xem

  Scenario: Alice wants to get her property name after registering asset with a valid property
    Given Alice registered a "<property>" asset for 1 day
    And she became the owner of this asset wtih a valid property
    When she wants to get her property name after registering asset with valid property
    Then she should find that she has the property "<property>"

  Scenario: Alice wants to see divisibility of registered asset
    Given Alice registered an asset with divisibility <divisibility> for 1 day
    And she became the owner the new asset
    When Alice wants to see the divisibility of registered asset
    Then Alice should see that her registered asset can handle up to <divisibility> decimals

 # Status errors not treated:
  # - Failure_Mosaic_Invalid_Name
  # - Failure_Mosaic_Name_Id_Mismatch
  # - Failure_Mosaic_Id_Mismatch
  # - Failure_Mosaic_Parent_Id_Conflict
  # - Failure_Mosaic_Invalid_Property
  # - Failure_Mosaic_Invalid_Flags
  # - Failure_Mosaic_Invalid_Id
