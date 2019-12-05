@not-implemented
Feature: Get the alias resolution for a given transaction
  As Alice
  I want to get the real identifier of the account or asset used in a transaction

  Background:
    Given "ticket_vendor_a" has address "SDCTIC-SWQBFV-VGOFEQ-27XY3G-LPOWHE-XRYJKP-TOPQ"
    And "ticket_vendor_b" has address "SATXKQ-QSWIMT-3S32BA-IEMZXD-P4HHUA-LDEYPL-EAZY"
    And "event.organizer" mosaic has the id "0dc67fbe1cad29e5"
    And "random.token" mosaic has the id "634a8ac3fc2b65b3"

  # Core
  Scenario: An account wants to get the address of an aliased recipient in a given transaction
    Given "Alice" sent 1 "event.organizer" to "ticket_vendor_a"
    When "Alice" wants to get the recipient address for the previous transaction
    Then "Alice" should get "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"

  Scenario: An account wants to get the identifier of the aliased asset used in a given transaction
    Given "Alice" sent 1 "event.organizer" to "ticket_vendor_a"
    When "Alice" wants to get "event.organizer" identifier  for the previous transaction
    Then "Alice" should get "0dc67fbe1cad29e5"

  Scenario: Same alias has multiple resolutions in the block
    Given the block "1" stores the following "TRANSFER" transactions:
      | index | sender | recipient       | mosaic            |
      | 1     | Alice  | ticket_vendor_a | 1 event.organizer |
      | 2     | Alice  | ticket_vendor_b | 2 event.organizer |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "2"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    And the block "1" should have 1 mosaic resolution statements

  Scenario: Different aliases have resolutions in the block
    Given the block "2" stores the following "TRANSFER" transactions:
      | index | sender | recipient       | mosaic            |
      | 1     | Alice  | ticket_vendor_a | 1 event.organizer |
      | 2     | Alice  | ticket_vendor_b | 1 random.token    |
      | 3     | Alice  | ticket_vendor_b | 2 event.organizer |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "2"
    Then the mosaic id should be "634a8ac3fc2b65b3"
    When "Alice" wants to get the mosaic identifier for the transaction with index "3"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    And the block "2" should have 2 mosaic resolution statements

  Scenario: Alias resolution change in the block
    Given the block "3" stores the following "TRANSFER" transactions:
      | index | sender | recipient       | mosaic            |
      | 1     | Alice  | ticket_vendor_a | 1 event.organizer |
    And the block "3" stores the following "Aggregate" transactions:
      | index | sender | transaction      | action            | mosaicId         | namespaceId     |
      | 2     | Alice  | MosaicAlias      | UNLINK            | 0dc67fbe1cad29e5 | event.organizer |
      | 2     | Alice  | MosaicAlias      | LINK              | 7cdf3b117a3c40cc | event.organizer |
    And the block "3" stores the following "TRANSFER" transactions:
      | index | sender | recipient       | mosaic            |
      | 3     | Alice  | ticket_vendor_a | 1 event.organizer |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "3"
    Then the mosaic id should be "7cdf3b117a3c40cc"
    And the block "3" should have 2 mosaic resolution statements

  Scenario: Same alias has multiple resolutions in the block (AGGREGATE)
    Given the block "4" stores the following "AGGREGATE" transactions:
      | index | sender | action             | mosaicId         | recipient        |
      | 1     | Alice  | TRANSFER           | event.organizer  | ticket_vendor_a  |
      | 1     | Alice  | TRANSFER           | event.organizer  | ticket_vendor_b  |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "2"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    And the block "4" should have 1 mosaic resolution statements

  Scenario:  Different aliases have resolutions in the block (AGGREGATE)
    Given the block "5" stores the following "AGGREGATE" transactions:
      | index | sender | action             | mosaicId         | recipient        |
      | 1     | Alice  | TRANSFER           | event.organizer  | ticket_vendor_a  |
      | 1     | Alice  | TRANSFER           | random.token     | ticket_vendor_b  |
      | 1     | Alice  | TRANSFER           | event.organizer  | ticket_vendor_b  |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "2"
    Then the mosaic id should be "634a8ac3fc2b65b3"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "3"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    And the block "5" should have 2 mosaic resolution statements

  Scenario: Alias resolution change in the block (more than one AGGREGATE)
    Given the block "6" stores the following "AGGREGATE" transactions:
      | index | sender |  action            | mosaicId         | namespaceId     | recipient       |
      | 1     | Alice  | TRANSFER           | event.organizer  |                 | ticket_vendor_a |
      | 1     | Alice  | MosaicAlias_UNLINK | 0dc67fbe1cad29e5 | event.organizer |                 |
      | 1     | Alice  | MosaicAlias_LINK   | 7cdf3b117a3c40cc | event.organizer |                 |
      | 1     | Alice  | TRANSFER           | event.organizer  |                 | ticket_vendor_b |
      | 1     | Alice  | MosaicAlias_UNLINK | 7cdf3b117a3c40cc | event.organizer |                 |
      | 1     | Alice  | MosaicAlias_LINK   | 0dc67fbe1cad29e5 | event.organizer |                 |
      | 1     | Alice  | TRANSFER           | event.organizer  |                 | ticket_vendor_b |
      | 2     | Alice  | TRANSFER           | event.organizer  |                 | ticket_vendor_a |
      | 2     | Alice  | MosaicAlias_UNLINK | 0dc67fbe1cad29e5 | event.organizer |                 |
      | 2     | Alice  | MosaicAlias_LINK   | 7cdf3b117a3c40cc | event.organizer |                 |
      | 2     | Alice  | TRANSFER           | event.organizer  |                 | ticket_vendor_b |
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "4"
    Then the mosaic id should be "7cdf3b117a3c40cc"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "7"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "2" and subindex "1"
    Then the mosaic id should be "0dc67fbe1cad29e5"
    When "Alice" wants to get the mosaic identifier for the transaction with index "1" and subindex "4"
    Then the mosaic id should be "7cdf3b117a3c40cc"
    And the block "6" should have 4 mosaic resolution statements
