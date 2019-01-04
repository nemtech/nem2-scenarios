Feature: Prevent sending transactions by type
  As Alice
  I want to prevent sending assets from my account
  So that I can ensure I don't send any of my assets while accepting escrow contracts

  Background:
    Given the following transaction types are available:
      |type                            |
      | TRANSFER                       |
      | REGISTER_NAMESPACE             |
      | ACCOUNT_PROPERTIES_ENTITY_TYPE |
    # We are using three transaction types for better comprehension.
    # To get all the available transaction types, see the NEM Developer Center/Protocol/Transaction.

  Scenario: An account blocks sending transactions with a given transaction type
    When Alice blocks sending transactions with type:
      | type               |
      | TRANSFER           |
      | REGISTER_NAMESPACE |
    Then she should receive a confirmation message
    And sending transactions with the stated transaction types should be blocked

  Scenario: An account allows only sending transactions with a given transaction type
    When Alice only allows sending transactions with type:
      | type               |
      | TRANSFER           |
      | REGISTER_NAMESPACE |
    Then she should receive a confirmation message
    And  only sending transactions with the stated transaction types should be allowed

  Scenario: An account unblocks a transaction type
    Given Alice blocked sending transactions with type:
      | type               |
      | TRANSFER           |
      | REGISTER_NAMESPACE |
    When Alice unblocks "TRANSFER"
    Then she should receive a confirmation message
    And only "REGISTER_NAMESPACE" should remain blocked

  Scenario: An account removes a transaction type from the allowed transaction types
    Given Alice only allowed sending "TRANSFER" transactions
      | type               |
      | TRANSFER           |
      | REGISTER_NAMESPACE |
    When Alice removes "TRANSFER" from the allowed transaction types
    Then she should receive a confirmation message
    And only "REGISTER_NAMESPACE" should remain allowed

  Scenario: An account unblocks a transaction type that is not blocked
    Given Alice blocked sending "TRANSFER" transactions
    When Alice unblocks "REGISTER_NAMESPACE"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account removes a transaction type that does not exist in the allowed transaction types
    Given Alice blocked sending "TRANSFER" transactions
    When Alice removes "REGISTER_NAMESPACE" from the allowed transaction types
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries only to  allow sending transactions with a given type when it has blocked types
    Given Alice blocked sending "TRANSFER" transactions
    When Alice only allows sending "REGISTER_NAMESPACE" transactions
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block sending transactions with a given type when it has allowed types
    Given Alice only allowed sending "TRANSFER" transactions
    When Alice blocks sending "REGISTER_NAMESPACE" transactions
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block a transaction type twice
    Given Alice blocked sending "TRANSFER" transactions
    When Alice blocks sending "TRANSFER" transactions
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to allow a transaction type twice
    Given Alice only allowed sending "TRANSFER" transactions
    When Alice only allows sending "TRANSFER" transactions
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to block a transaction with "ACCOUNT_PROPERTIES_ENTITY_TYPE" type
    When Alice blocks sending "ACCOUNT_PROPERTIES_ENTITY_TYPE" transactions
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"
