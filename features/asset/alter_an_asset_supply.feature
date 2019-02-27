Feature: Alter an asset supply
  As Alice
  I want to alter an asset supply
  So that it represents the available amount of an item in my shop.

  Background:
    Given the mean block generation time is 15 seconds
    And the maximum asset supply is 9000000000
    And Alice has 10000000 xem in her account

  Scenario Outline: An account alters an asset supply
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in <amount> units
    Then she should receive a confirmation message
    And the balance of the asset in her account should "<direction>" in <amount> units
    # Mosaic_Rental_Fee

    Examples:
      | property         | direction | amount |
      | supply-mutable   | increase  | 5      |
      | supply-immutable | increase  | 5      |
      | supply-mutable   | decrease  | 20     |
      | supply-immutable | decrease  | 20     |

  Scenario Outline: An account tries to alter an asset supply surpassing the maximum or minimum asset supply limit
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in <amount> units
    Then she should receive the error "<error>"
    # Mosaic_Rental_Fee

    Examples:
      | property         | direction | amount     | error                          |
      | supply-mutable   | increase  | 9000000000 | Failure_Mosaic_Supply_Exceeded |
      | supply-immutable | increase  | 9000000000 | Failure_Mosaic_Supply_Exceeded |
      | supply-mutable   | decrease  | 21         | Failure_Mosaic_Supply_Negative |
      | supply-immutable | decrease  | 21         | Failure_Mosaic_Supply_Negative |

  Scenario Outline: An account tries to alter an asset supply without doing any changes
    Given Alice has registered a <property> asset with an initial supply of 20 units
    And she still owns 20 units
    When Alice decides to "<direction>" the asset supply in 0 units
    Then she should receive the error "Failure_Mosaic_Invalid_Supply_Change_Amount"
    # Mosaic_Rental_Fee

    Examples:
      | property         | direction |
      | supply-mutable   | increase  |
      | supply-immutable | increase  |
      | supply-mutable   | decrease  |
      | supply-immutable | decrease  |

  Scenario Outline: An account tries to alter the supply of a supply immutable asset but does not own all the units
    Given Alice has registered a "supply-immutable" asset with an initial supply of 20 units
    And she still owns 10 units
    When Alice decides to "<direction>" the asset supply in 2 units
    Then she should receive the error "Failure_Mosaic_Supply_Immutable"
    # Mosaic_Rental_Fee

    Examples:
      | direction |
      | increase  |
      | decrease  |

  Scenario: An account tries to alter a non-changeable asset property
    Given Alice has registered an asset with divisibility 6
    When Alice changes the divisibility to 5
    Then she should receive the error "Failure_Mosaic_Modification_Disallowed"
  # Mosaic_Rental_Fee

  Scenario: An account tries to alter an asset supply but has not allowed sending "MOSAIC_SUPPLY_CHANGE" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice has registered a "supply-mutable" asset with an initial supply of 20 units
    When Alice decides to "increase" the asset supply in 5 units
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to alter an asset supply but has blocked sending "MOSAIC_SUPPLY_CHANGE" transactions
    Given Alice blocked sending "MOSAIC_DEFINITION" transactions
    And Alice has registered a "supply-mutable" asset with an initial supply of 20 units
    When Alice decides to "increase" the asset supply in 5 units
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  # Status errors not treated:
  # - Failure_Mosaic_Invalid_Supply_Change_Direction
  # - Failure_Mosaic_Modification_No_Changes


# Receipt Behavior
  # Mosaic_Rental_Fee
  Scenario: Alice wants to get the asset balance after altering supply
    Given Alice "<direction>" the asset supply in <amount> units
    When Alice want to get asset balance after <direction> asset supply
    Then Alice should see asset balance is "<direction>" by <amount> in her account

  # Mosaic_Rental_Fee
  Scenario: Alice wants to get the asset balance after altering supply to surpass maximum and minimum asset supply
    Given Alice "<direction>" the asset supply by <amount> units beyond supply limit
    When Alice want to get asset balance after <direction> asset supply
    Then Alice should receive the error "<error>"

  # Mosaic_Rental_Fee
  Scenario: Alice wants to get the asset balance after altering supply without doing any changes
    Given Alice "<direction>" the asset supply by 0 units
    When Alice want to get asset balance after <direction> asset supply
    Then Alice should receive the error "<error>"
