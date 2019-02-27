Feature: Prevent receiving transactions from undesired addresses
  As Alice
  I don't want to receive assets from Bob
  So that I have control of which accounts can send me transactions

  Background:
    Given the following accounts exists:
      | account |
      | Alice   |
      | Bob     |
      | Carol   |
    And an account can only define up to 512 address filters

  Scenario: An account blocks receiving transactions from a set of addresses
    When Alice blocks receiving transactions from:
      | signer |
      | Bob    |
      | Carol  |
    Then she should receive a confirmation message
    And receiving transactions from the stated addresses should be blocked

  Scenario: An account allows only receiving transactions from a set of addresses
    When Alice only allows receiving transactions from:
      | signer |
      | Bob    |
      | Carol  |
    Then she should receive a confirmation message
    And  only receiving transactions from the stated addresses should be allowed

  Scenario: An account unblocks an address
    Given Alice blocked receiving transactions from:
      | signer |
      | Bob    |
      | Carol  |
    When Alice unblocks "Bob"
    Then she should receive a confirmation message
    And only Carol should remain blocked

  Scenario: An account removes an address from the allowed addresses
    Given Alice only allowed receiving transactions from "Bob"
      | signer |
      | Bob    |
      | Carol  |
    When Alice removes "Bob" from the allowed addresses
    Then she should receive a confirmation message
    And only Carol should remain allowed

  Scenario: An account unblocks a not blocked address
    Given Alice blocked receiving transactions from "Bob"
    When Alice unblocks "Carol"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account removes an address that does not exist in the allowed addresses
    Given Alice blocked receiving transactions from "Bob"
    When Alice removes "Carol" from the allowed addresses
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries only to allow receiving transactions from a set of addresses when it has blocked addresses
    Given Alice blocked receiving transactions from "Bob"
    When Alice only allows receiving transactions from "Carol"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block receiving transactions from a set of addresses when it has allowed addresses
    Given Alice only allowed receiving transactions from "Bob"
    When Alice blocks receiving transactions from "Carol"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block an address twice
    Given Alice blocked receiving transactions from "Bob"
    When Alice blocks receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to allow an address twice
    Given Alice only allowed receiving transactions from "Bob"
    When Alice only allows receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to block herself
    When Alice blocks receiving transactions from herself:
    Then she should receive the error "Failure_Property_Modification_Address_Invalid"

  Scenario: An account tries to only allow itself
    When Alice only allows receiving transactions from herself
    Then she should receive the error "Failure_Property_Modification_Address_Invalid"

  Scenario: An account tries to block too many addresses
    Given Alice blocked receiving transactions from 512 addresses
    When Alice blocks receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Values_Count_Exceeded"

  Scenario: An account tries to only allow too many addresses
    Given Alice only allowed receiving transactions from 512 addresses
    When Alice only allows receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Values_Count_Exceeded"

  Scenario: An account tries to block too many addresses in a single transaction
    When Alice blocks receiving transactions from 513 addresses
    Then she should receive the error "Failure_Property_Modification_Count_Exceeded"

  Scenario: An account tries to only allow too many addresses in a single transaction
    When Alice only allows receiving transactions from 513 addresses
    Then she should receive the error "Failure_Property_Modification_Count_Exceeded"

  Scenario Outline: An account tries to block an invalid address
    When Alice blocks receiving transactions from "<address>"
    Then she should receive the error "<error>"

    Examples:
      | address                                       | error                             |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H | Failure_Core_Invalid_Address      |
      | bo                                            | Failure_Core_Invalid_Address      |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5| Failure_Core_Wrong_Network        |

  Scenario Outline: An account tries only allow transactions from an invalid address
    When Alice only allows receiving transactions from "<address>"
    Then she should receive the error "<error>"

    Examples:
      | address                                       | error                             |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H | Failure_Core_Invalid_Address      |
      | bo                                            | Failure_Core_Invalid_Address      |
      | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5| Failure_Core_Wrong_Network        |


# Receipts Behavior
  # Transaction_Group receipt
  Scenario: Alice wants to get the state change of blocking address transaction
    Given Alice blocks the receiving transactions from certain address
    When Alice wants to get the state change of the her address blocking transaction
    Then Alice should get the "confirmed" status of the address blocking transaction

  # Transaction_Group Receipt
  Scenario: Alice wants to get the state change of filtering address transactions
    Given Alice specifies to only receive transactions from certain addresses
    When Alice wants to get the state change of the address filter transaction
    Then Alice should get the "confirmed" status of the address filter transaction

  # Transaction_Group Receipt
  Scenario: Alice wants to get the state change of unblocking an address
    Given Alice unblocks "Bob" 
    And keeps "Carol" blocked
    When Alice wants to get the state change of her address unblock transaction
    Then Alice should get the "confirmed" status of the address unblock transaction

  # Transaction_Group receipts
  Scenario: Alice wants to get the state change of remove address transaction
    Given Alice only allows receiving from "Bob"
    And she removes "Bob" from allowed addresses
    And "Carol" should remain allowed
    When Alice wants to get the state change of the address removal transaction
    Then Alice should get the "confirmed" status of the address removal transaction
