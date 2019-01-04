Feature: Prevent receiving transactions from undesired addresses
  As Alice
  I don't want to receive assets from Bob
  So that I have control of which accounts can send me transactions

  Background:
    Given the following accounts exists:
      |account|
      |Alice  |
      |Bob    |
      |Carol  |

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
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to block an address twice
    Given Alice blocked receiving transactions from "Bob"
    When Alice blocks receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to allow an address twice
    Given Alice only allowed receiving transactions from "Bob"
    When Alice only allows receiving transactions from "Bob"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block herself
    When Alice blocks herself
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"
