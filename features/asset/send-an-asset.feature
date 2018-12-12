Feature: Send an asset
  As Alice
  I want to send 1 concert ticket to Bob
  So that he can attend the event.

  Background:
    Given the mean block generation time is 15 seconds
    And the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5" is named "bob"
    And the address "SAPUUH-GL6DYO-ZHTCAE-ORM2MB-KBXOI5-UZILYE-6RV4" is named "ticket-vendor"
    And "ticket-vendor" created the asset "3576016194"  named "concert.ticket" with an initial supply of 1000 units and non-divisible
    And "ticket-vendor" created the asset "3576016195" named "reward.point" with an initial supply of 1000 units and divisible up to 2 decimals
    And "ticket-vendor" created the non-transferable asset "3576016196" named "event.organizer" with an initial supply of 1000 units and non-divisible
    And Alice has the following mosaics in her account:
      | asset-name      | amount |
      | concert.ticket  | 100    |
      | reward.point    | 100    |
      | event.organizer | 2      |

  Scenario Outline: An account sends an asset to another account
    When Alice sends  <amount> "<asset>" to "bob"
    Then "bob" should receive  <amount> "<asset>"
    And  her "<asset>" balance should decrease in <amount> unit

    Examples:
      | amount | asset          |
      | 1      | concert.ticket |
      | 2      | 3576016194     |
      | 0.5    | reward.point   |

  Scenario Outline: An account tries to send an asset to an invalid account
    When Alice sends 1 "concert.ticket" to <recipient>
    Then she should receive the error "<error>"
    And her "concert.ticket" balance should remain intact

    Examples:
      | recipient                                      | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | Failure_Core_Invalid_Address |
      | bo                                             | Failure_Core_Invalid_Address |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Wrong_Network   |

  Scenario Outline: An account tries to send assets that it does not have

    When Alice sends <amount> "<asset>" to "bob"
    Then she should receive the error "<error>"
    And her "<asset>" balance should remain intact

    Examples:
      | amount | asset          | error                            |
      | -1     | concert.ticket | Failure_Core_Insufficient_Balance|
      | 1      | unknown.ticket | Failure_Mosaic_Expired           |
      | 1      | xem            | Failure_Core_Insufficient_Balance|
      | 105    | concert.ticket | Failure_Core_Insufficient_Balance|

  Scenario Outline: An account tries to split an asset that can't be split
    When Alice sends  <amount> "<asset>" to "bob"
    Then "bob" should not receive any asset
    And her "<asset>" balance should remain intact

    Examples:
      | amount  | asset          |
      | 0.5     | concert.ticket |
      | 0.000005| reward.point   |

  Scenario: An account that created a non-transferable asset sends it to another account
    When The ticket vendor sends 1 "event.organizer" to "bob"
    Then "bob" should receive 1 "event.organizer"
    And  the ticket vendor "event.organizer" balance should decrease in 1 unit(s)

  Scenario: An account sends a non-transferable asset to the account that created the asset
    When Alice sends 1 "event.organizer" to "ticket-vendor"
    Then "ticket-vendor" should receive 1 "event.organizer"
    And  her "event.organizer" balance should decrease in 1 unit(s)

  Scenario: An account tries to send a non-transferable asset to another account
    When Alice sends  1 "event.organizer" to "bob"
    Then she should receive the error "Failure_Mosaic_Non_Transferable"
    And her "event.organizer" balance should remain intact

  Scenario: An account sends multiple assets to another account
    When Alice sends 1 "concert.ticket" and 2 "reward.point" to "bob"
    Then "bob" should receive 1 "concert.ticket" and 2 "reward.point"
    And  her "concert.ticket" balance should decrease in 1 unit(s)
    And  her "reward.point" balance should decrease in 2 unit(s)

  Scenario Outline: An account tries to send multiple assets to another account, but there is an error in at least one of the attached assets
    When Alice sends <amount-1> "<asset-1>" and 1 reward.point to "bob"
    Then she should receive the error "<error>"
    And her "<asset-1>" balance should remain intact
    And her "reward.point" balance should remain intact

    Examples:
      | amount-1 | asset-1        | error                                 |
      | 500      | concert.ticket | Failure_Core_Insufficient_Balance     |
      | 1        | unknown.ticket | Failure_Mosaic_Expired                |
      | 1        | event.organizer| Failure_Mosaic_Non_Transferable       |
      | 1        | reward.point   | Failure_Transfer_Out_Of_Order_Mosaics |
