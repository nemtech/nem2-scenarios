Feature: Send an asset
  As Alice
  I want to send 1 concert ticket to Bob
  So that he can attend the event.

  Background:
    Given Alice registered the asset "X"
    And Alice registered the asset "Y"

  @bvt
  Scenario Outline: An account sends an asset to another account
    When Alice sends <amount> asset "<asset>" to Bob
    Then she should receive a confirmation message
    And Bob should receive <amount> of asset "<asset>"
    And Alice "<asset>" balance should decrease in <amount> unit

    Examples:
      | amount | asset |
      | 1      | X     |
      | 2      | Y     |

  Scenario: An account sends an asset to itself
    When Alice sends 1 asset "X" to Alice
    Then she should receive a confirmation message
    And Alice balance should remain intact

  @bvt
  Scenario Outline: An account tries to send an asset to an invalid account
    When Alice tries to send 1 asset "Y" to <recipient>
    Then she should receive the error "<error>"
    And Alice balance should remain intact
    Examples:
      | recipient                                      | error                        |
      | NAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3HT | Failure_Core_Invalid_Address |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Invalid_Address |

  @bvt
  Scenario Outline: An account tries to send assets that does not have
    When Alice tries to send <amount> asset "<asset>" to Sue
    Then she should receive the error "<error>"
    And Alice balance should remain intact

    Examples:
      | amount | asset   | error                             |
      | -1     | X       | Failure_Core_Insufficient_Balance |
      | 1      | O       | Failure_Core_Insufficient_Balance |
      | 1      | unknown | Failure_Core_Insufficient_Balance |
      | 105    | Y       | Failure_Core_Insufficient_Balance |

  @bvt
  Scenario: An account sends multiple assets to another account
    When Alice sends 1 asset "X" and 2 asset "Y" to Bob
    Then she should receive a confirmation message
    And Bob should receive 1 of asset "X"
    And Bob should receive 2 of asset "Y"
    And Alice "X" balance should decrease in 1 unit
    And Alice "Y" balance should decrease in 2 units

  @bvt
  Scenario Outline: An account tries to send multiple assets to another account but at least one of the attached assets can't be sent
    When Alice tries to send <amount> asset "<asset>" and 1 asset "Y" to "Bob"
    Then she should receive the error "<error>"
    And Alice balance should remain intact

    Examples:
      | amount | asset  | error                                 |
      | 500    | X      | Failure_Core_Insufficient_Balance     |
      | 1      | U      | Failure_Core_Insufficient_Balance     |
      | 1      | Y      | Failure_Transfer_Out_Of_Order_Mosaics |

  @bvt
  Scenario: An account sends a non-transferable asset to the account that registered the asset
    Given Alice registers a non transferable asset which she transfer 10 asset to Sue
    When Sue transfer 1 asset to Alice
    Then 1 asset transfered successfully

  @bvt
  Scenario: An account tries to send a non-transferable asset to another account
    Given Alice registers a non transferable asset which she transfer 10 asset to Sue
    When Sue transfer 1 asset to Bob
    Then she should receive the error "Failure_Mosaic_Non_Transferable"

  @bvt
  Scenario: An account transfer a transferable asset to another account
    Given Alice registers a transferable asset which she transfer asset to Bob
    When Bob transfer 10 asset to Sue
    Then 10 asset transfered successfully

  @bvt
  Scenario: An account tries to send an expired asset
    Given Alice has registered expiring asset for 2 blocks
    And the asset is now expired
    When Alice transfer 1 asset to Bob
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  @not-implemented
  Scenario: An account tries to split an asset that can't be split
    Given ticket has divisibility 0
    When "Alice" sends 0.5 "ticket" to "Bob"
    Then "Bob" should not receive any asset
    And "Alice" <asset>" balance should remain intact

  @not-implemented
  Scenario: An account that registered a non-transferable asset sends it to another account
    When "ticket_vendor" sends 1 "event.organizer" to "Bob"
    Then "ticket_vendor" should receive a confirmation message
    And "Bob" should receive 1 "event.organizer"
    And "ticket_vendor" "event.organizer" balance should decrease in 1 unit(s)

  # Account Restrictions
  @not-implemented
  Scenario: An account tries to send an asset to another account but the second account does not allow this asset
    Given Bob only allowed receiving "cat.currency"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact

  @not-implemented
  Scenario: An account tries to send an asset to another account but the second account has blocked this asset
    Given Bob blocked receiving "cat.currency"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact

  @not-implemented
  Scenario: An account tries to send an asset to another account but has not allowed sending "TRANSFER" transactions
    Given Alice only allowed sending "REGISTER_NAMESPACE" transactions
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact

  @not-implemented
  Scenario: An account tries to send an asset to another account but has blocked sending "TRANSFER" transactions
    Given Alice blocked sending "TRANSFER" transactions
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact

  @not-implemented
  Scenario: An account tries to send an asset to another account but the second account does not allow it
    Given Bob only allowed receiving transactions from Carol's address
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Signer_Address_Interaction_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact

  @not-implemented
  Scenario: An account tries to send an asset to another account but the second account blocked it
    Given Bob blocked receiving transactions from Alice's address"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_RestrictionAccount_Address_Interaction_Not_Allowed"
    And "Alice" "concert.ticket" balance should remain intact
