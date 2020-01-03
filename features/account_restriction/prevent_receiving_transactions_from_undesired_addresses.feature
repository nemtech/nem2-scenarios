Feature: Prevent receiving transactions from undesired addresses
  As Alex
  I don't want to receive assets from Bobby
  So that I have control of which accounts can send me transactions
#  TODO: this and other restriction features do not have scenarios considering the direction of allow/block.
#   Scenario:
#  ALLOW_INCOMING_ADDRESS - done, ALLOW_OUTGOING_ADDRESS - not done!

  Background:
    Given the following accounts exist:
      | Alex    |
      | Bobby   |
      | Carol   |

  Scenario: An account blocks receiving transactions from a set of addresses
    Given Bobby blocked receiving transactions from:
      | Alex   |
      | Carol  |
    When Alex tries to send 1 asset "cat.currency" to Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_ADDRESS_INTERACTION_PROHIBITED"

  Scenario: An account in only allowed list should successfully send assets to recepient address
    Given Bobby only allowed receiving transactions from:
      | Alex   |
    When Alex sends 1 asset "cat.currency" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive 1 of asset "cat.currency"
    And Alex "cat.currency" balance should decrease by 1 unit

  Scenario: An account not in only allowed list should receive error
    Given Bobby only allowed receiving transactions from:
      | Alex   |
    When Carol tries to send 1 asset "cat.currency" to Bobby
    Then Carol should receive the error "FAILURE_RESTRICTIONACCOUNT_ADDRESS_INTERACTION_PROHIBITED"

  Scenario: A blocked account when unblocked should be able to transfer assets to recepient
    Given Bobby blocked receiving transactions from:
      | Alex  |
      | Carol  |
    And Bobby removes Alex from blocked addresses
    When Alex sends 1 asset "cat.currency" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive 1 of asset "cat.currency"
    And Alex "cat.currency" balance should decrease by 1 unit
  
  Scenario: A blocked account should remain blocked when others are unblocked
    Given Bobby blocked receiving transactions from:
      | Alex  |
      | Carol  |
    And Bobby removes Alex from blocked addresses
    When Carol tries to send 1 asset "cat.currency" to Bobby
    Then Carol should receive the error "FAILURE_RESTRICTIONACCOUNT_ADDRESS_INTERACTION_PROHIBITED"

  Scenario: An account removes an address from the allowed addresses
    Given Bobby only allowed receiving transactions from:
      | Alex  |
      | Carol |
    And Bobby removes Alex from allowed addresses
    When Alex tries to send 1 asset "cat.currency" to Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_ADDRESS_INTERACTION_PROHIBITED"
  
  Scenario: An account removes an address from the allowed addresses
    Given Bobby only allowed receiving transactions from:
      | Alex  |
      | Carol |
    And Bobby removes Alex from allowed addresses
    When Carol sends 1 asset "cat.currency" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive 1 of asset "cat.currency"
    And Carol "cat.currency" balance should decrease by 1 unit

  Scenario: An account unblocks a not blocked address
    Given Bobby blocked receiving transactions from:
      | Alex |
    When Bobby tries to remove Carol from blocked addresses
    Then Bobby should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_NOT_ALLOWED"

  Scenario: An account removes an address that does not exist in the allowed addresses
    Given Bobby only allowed receiving transactions from:
      | Alex |
    When Bobby tries to remove Carol from allowed addresses
    Then Bobby should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_NOT_ALLOWED"

  Scenario: An account tries only to allow receiving transactions from a set of addresses when it has blocked addresses
    Given Bobby blocked receiving transactions from:
      | Alex |
    When Bobby tries to only allow receiving transactions from Carol
    Then Bobby should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_NOT_ALLOWED"

  Scenario: An account tries to block receiving transactions from a set of addresses when it has allowed addresses
    Given Bobby only allowed receiving transactions from:
      | Alex |
    When Bobby tries to block receiving transactions from Carol
    Then Bobby should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_NOT_ALLOWED"

  Scenario: An account tries to block an address twice
    Given Alex blocked receiving transactions from:
      | Bobby |
    When Alex tries to block receiving transactions from Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_REDUNDANT"

  Scenario: An account tries to allow an address twice
    Given Alex only allowed receiving transactions from:
      | Bobby |
    When Alex tries to only allow receiving transactions from Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_REDUNDANT"

  Scenario: An account tries to block self
    When Alex tries to block receiving transactions from herself
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_ADDRESS_INVALID"

  Scenario: An account tries to only allow self
    When Alex tries to only allow receiving transactions from herself
    Then she should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_ADDRESS_INVALID"

  Scenario: An account tries to block too many addresses
    Given Alex has blocked receiving transactions from 512 different addresses
    When Alex tries to block receiving transactions from Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_VALUES_COUNT_EXCEEDED"

  Scenario: An account tries to only allow too many addresses
    Given Alex has allowed receiving transactions from 512 different addresses
    When Alex tries to only allow receiving transactions from Bobby
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_VALUES_COUNT_EXCEEDED"

  Scenario: An account tries to block too many addresses in a single transaction
    Given there are at least 515 different addresses registered
    When Alex tries to block receiving transactions from 513 different addresses
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_COUNT_EXCEEDED"

  Scenario: An account tries to only allow too many addresses in a single transaction
    Given there are at least 515 different addresses registered
    When Alex tries to only allow receiving transactions from 513 different addresses
    Then Alex should receive the error "FAILURE_RESTRICTIONACCOUNT_MODIFICATION_COUNT_EXCEEDED"

  Scenario Outline: An account tries to block an invalid address
    When Alex tries to block receiving transactions from "<address>"
    Then Alex should receive the error "<error>"

    Examples:
      | address                                        | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | FAILURE_CORE_INVALID_ADDRESS |
      | bo                                             | FAILURE_CORE_INVALID_ADDRESS |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | FAILURE_CORE_WRONG_NETWORK   |

  Scenario Outline: An account tries only allow transactions from an invalid address
    When Alex tries to only allow receiving transactions from "<address>"
    Then Alex should receive the error "<error>"

    Examples:
      | address                                        | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | FAILURE_CORE_INVALID_ADDRESS |
      | bo                                             | FAILURE_CORE_INVALID_ADDRESS |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | FAILURE_CORE_WRONG_NETWORK   |
