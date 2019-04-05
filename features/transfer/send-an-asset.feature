Feature: Send an asset
  As Alice
  I want to send 1 concert ticket to Bob
  So that he can attend the event.

  Background:
    Given the mean block generation time is 15 seconds
    And "ticket_vendor" has the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    And "ticket_vendor" has registered the following assets:
      | id               | alias           | transferable | supply | divisibility |
      | 0dc67fbe1cad29e3 | concert.ticket  | true         | 1000   | 0            |
      | 0dc67fbe1cad29e4 | reward.point    | false        | 1000   | 2            |
      | 0dc67fbe1cad29e5 | event.organizer | true         | 1000   | 0            |

    And Alice has the following assets in her account:
      | asset           | amount |
      | concert.ticket  | 100    |
      | reward.point    | 100    |
      | event.organizer | 2      |

  Scenario Outline: An account sends an asset to another account
    When "Alice" sends  <amount> "<asset>" to "Bob"
    Then "Alice" should receive a confirmation message
    And "Bob" should receive <amount> "<asset>"
    And "Alice" <asset>" balance should decrease in <amount> unit(s)

    Examples:
      | amount | asset            |
      | 1      | concert.ticket   |
      | 2      | 0dc67fbe1cad29e3 |
      | 0.5    | reward.point     |

  Scenario: An account sends an asset to itself
    When "Alice" sends  1 "concert.ticket" to "Alice"
    Then "Alice" should receive a confirmation message
    And "Alice" should receive 1 "concert.ticket"
    And "Alice" concert.ticket" balance should remain intact

  Scenario Outline: An account tries to send an asset to an invalid account
    When "Alice" sends 1 "concert.ticket" to "<recipient>"
    Then she should receive the error "<error>"
    And "Alice" concert.ticket" balance should remain intact

    Examples:
      | recipient                                      | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | Failure_Core_Invalid_Address |
      | bo                                             | Failure_Core_Invalid_Address |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Wrong_Network   |

  Scenario Outline: An account tries to send assets that does not have
    When "Alice" sends <amount> "<asset>" to "Bob"
    Then she should receive the error "<error>"
    And "Alice" <asset>" balance should remain intact

    Examples:
      | amount | asset          | error                             |
      | -1     | concert.ticket | Failure_Core_Insufficient_Balance |
      | 1      | unknown.ticket | Failure_Mosaic_Expired            |
      | 1      | xem            | Failure_Core_Insufficient_Balance |
      | 105    | concert.ticket | Failure_Core_Insufficient_Balance |

  Scenario Outline: An account tries to split an asset that can't be split
    When "Alice" sends <amount> "<asset>" to "Bob"
    Then "Bob" should not receive any asset
    And "Alice" <asset>" balance should remain intact

    Examples:
      | amount   | asset          |
      | 0.5      | concert.ticket |
      | 0.000005 | reward.point   |

  Scenario: An account that registered a non-transferable asset sends it to another account
    When "ticket_vendor" sends 1 "event.organizer" to "Bob"
    Then "ticket_vendor" should receive a confirmation message
    And "Bob" should receive 1 "event.organizer"
    And "ticket_vendor" "event.organizer" balance should decrease in 1 unit(s)

  Scenario: An account sends a non-transferable asset to the account that registered the asset
    When "Alice" sends 1 "event.organizer" to "ticket_vendor"
    Then she should receive a confirmation message
    And "ticket_vendor" should receive 1 "event.organizer"
    And  "Alice" event.organizer" balance should decrease in 1 unit(s)

  Scenario: An account tries to send a non-transferable asset to another account
    When "Alice" sends 1 "event.organizer" to "Bob"
    Then she should receive the error "Failure_Mosaic_Non_Transferable"
    And "Alice" event.organizer" balance should remain intact

  Scenario: An account sends multiple assets to another account
    When "Alice" sends 1 "concert.ticket" and 2 "reward.point" to "Bob"
    Then she should receive a confirmation message
    And "Bob" should receive 1 "concert.ticket" and 2 "reward.point"
    And  "Alice" concert.ticket" balance should decrease in 1 unit(s)
    And  "Alice" reward.point" balance should decrease in 2 unit(s)

  Scenario Outline: An account tries to send multiple assets to another account but at least one of the attached assets can't be sent
    When "Alice" sends <amount> "<asset>" and 1 reward.point to "Bob"
    Then she should receive the error "<error>"
    And "Alice" <asset>" balance should remain intact
    And "Alice" reward.point" balance should remain intact

    Examples:
      | amount | asset           | error                                 |
      | 500    | concert.ticket  | Failure_Core_Insufficient_Balance     |
      | 1      | unknown.ticket  | Failure_Mosaic_Expired                |
      | 1      | event.organizer | Failure_Mosaic_Non_Transferable       |
      | 1      | reward.point    | Failure_Transfer_Out_Of_Order_Mosaics |

  Scenario: An account tries to send an asset to another account but the second account does not allow this asset
    Given Bob only allowed receiving "xem"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Mosaic_Transfer_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact

  Scenario: An account tries to send an asset to another account but the second account has blocked this asset
    Given Bob blocked receiving "xem"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Mosaic_Transfer_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact

  Scenario: An account tries to send an asset to another account but has not allowed sending "TRANSFER" transactions
    Given Alice only allowed sending "REGISTER_NAMESPACE" transactions
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact

  Scenario: An account tries to send an asset to another account but has blocked sending "TRANSFER" transactions
    Given Alice blocked sending "TRANSFER" transactions
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact

  Scenario: An account tries to send an asset to another account but the second account does not allow it
    Given Bob only allowed receiving transactions from Carol's address
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Signer_Address_Interaction_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact

  Scenario: An account tries to send an asset to another account but the second account blocked it
    Given Bob blocked receiving transactions from Alice's address"
    When "Alice" sends 1 "concert.ticket" to "Bob"
    Then she should receive the error "Failure_Property_Signer_Address_Interaction_Not_Allowed"
    And "Alice" concert.ticket" balance should remain intact
