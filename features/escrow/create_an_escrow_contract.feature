Feature: Create an escrow contract
  As Alice,
  I want to create an escrow contract between different participants,
  so that there is no need to trust in each other.

  Background:
    Given the maximum number of participants per escrow contract is 15
    And the maximum number of transactions per escrow contract is 1000
    And an escrow contract requires to lock at least 10 "xem" to guarantee that the it will conclude
    And an escrow contract is active up to 2 days
    And the mean block generation time is 15 seconds
    And Alice has at least 10 xem in her account

  Scenario: An account creates an escrow contract
    Given Alice defined the following escrow contract:
    | sender | recipient | type          | data            |
    | Alice  | Bob       | send-an-asset | 1 concert.ticket|
    | Bob    | Alice     | send-an-asset | 20 euros        |
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then every sender participant should receive a notification to accept the contract

  Scenario: An account creates an escrow contract adding a new participant
    Given Alice defined the following escrow contract:
      | sender  | recipient | type          | data            |
      | Alice   | Bob       | send-an-asset | 1 concert.ticket|
      | Bob     | Exchange  | send-an-asset | 20 xem          |
      | Exchange| Alice     | send-an-asset | 20 euros        |
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then every sender participant should receive a notification to accept the contract

  Scenario: An account creates an escrow contract signed by all the participants
    Given Alice defined the following escrow contract:
      | sender | recipient | type          | data            |
      | Alice  | Bob       | send-an-asset | 1 concert.ticket|
      | Bob    | Alice     | send-an-asset | 20 euros        |
    And every sender accepts the contract
    When she publishes the contract
    Then every sender participant should receive a confirmation notification
    And the swap of assets should conclude

  Scenario: An account creates an escrow contract using other types of transactions
    Given Alice defined the following escrow contract:
      | sender  | type                             | data                      |
      | Alice   | register-a-namespace             | alice                     |
      |  Bob    | create-a-multisignature-contract | 1-of-1, cosignatory:alice |
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then every sender participant should receive a notification to accept the contract

  Scenario: An account creates an escrow contract and another account locks the funds for that contract
    Given Alice defined a valid escrow contract
    And "Bob" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then every sender participant should receive a notification to accept the contract

  Scenario: An account creates an escrow contract locking more than 10 xem for that contract
    Given Alice defined a valid escrow contract
    And "Alice" locked 11 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then every sender participant should receive a notification to accept the contract

  Scenario: An account tries to create an escrow contract with too many transactions
    Given Alice defined an escrow contract involving more than 1000 transactions
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then she should receive the error "Failure_Aggregate_Too_Many_Transactions"

  Scenario: An account tries to create an escrow contract with too many different participants
    Given Alice defined an escrow contract involving 16 different accounts
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then she should receive the error "Failure_Aggregate_Too_Many_Cosignatures"

  Scenario: An account tries to create an empty escrow contract
    Given Alice defined an escrow contract
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then she should receive the error "Failure_Aggregate_No_Transactions"

  Scenario: An account tries to create an escrow contract inside an escrow contract
    Given Alice defined an escrow contract inside an escrow contract
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then she should receive the error "Not possible to nest aggregate transactions"

  Scenario: An account tries to create an escrow contract but the account will not do any transaction
    Given Alice defined an escrow contract
    And she stated that "Bob" will turn his account into multisig adding her as a cosignatory
    And "Alice" locked 10 "xem" three days ago for that contract
    When she publishes the contract
    Then she should receive the error "Failure_Aggregate_Ineligible_Cosigners"

  Scenario: An account tries to create an escrow contract but the lock expired
    Given Alice defined a valid escrow contract
    And "Alice" locked 10 "xem" three days ago for that contract
    When she publishes the contract
    Then she should receive the error "Failure_LockHash_Inactive_Hash"

  Scenario: An account tries to create an escrow contract but the lock already exists
    Given Alice locked 10 "xem" to publish an escrow
    And "Alice" locked 10 "xem" for the same escrow
    Then she should receive the error "Failure_LockHash_Hash_Exists"

  Scenario: An account tries to create an escrow without locking funds in advance
    Given Alice defined a valid escrow contract
    When she publishes the contract
    Then she should receive the error "Failure_LockHash_Hash_Does_Not_Exist"

  Scenario: An account tries to create an escrow but locks another mosaic that is not xem
    Given Alice defined a valid escrow contract
    When Alice locks 10 "tickets" to guarantee that the contract will conclude in less than 2 days
    Then she should receive the error "Failure_LockHash_Invalid_Mosaic_Id"
    And her xem balance should remain intact

  Scenario: An account tries to create an escrow an escrow but locks less than 10 xem
    Given Alice defined a valid escrow contract
    When Alice locks 9 "xem" to guarantee that the contract will conclude in less than 2 days
    Then she should receive the error "Failure_LockHash_Invalid_Mosaic_Amount"
    And her xem balance should remain intact

  Scenario Outline: An account tries to create an escrow but sets an invalid duration
    Given Alice defined a valid escrow contract
    When Alice locks 10 "xem" to guarantee that the contract will conclude in less than <duration> days
    Then she should receive the error "Failure_LockHash_Invalid_Duration"
    And her xem balance should remain intact

    Examples:
      |duration|
      | -1     |
      | 0      |
      | 3      |

  Scenario: An account tries to create an escrow contract but does not have 10 xem
    Given Alice defined a valid escrow contract
    And Alice has expended all her xem
    When Alice locks 10 "xem" to guarantee that the contract will conclude in less than <duration> days
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  Scenario: An account tries to create an escrow already signed by the participants but at least one has not signed it
    Given Alice defined the following escrow contract:
      | sender | recipient | type          | data            |
      | Alice  | Bob       | send-an-asset | 1 concert.ticket|
      | Bob    | Alice     | send-an-asset | 20 euros        |
    And "Alice" accepts the contract
    When she publishes the contract
    Then she should receive the error "Failure_Aggregate_Missing_Cosigners"

  Scenario: An account tries to lock assets but has not allowed sending "LOCK_HASH" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice defined a valid escrow contract
    When "Alice" locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to create an escrow contract but has blocked sending "LOCK_HASH" transactions
    Given Alice blocked sending "LOCK_HASH" transactions
    And Alice defined a valid escrow contract
    When "Alice" locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to create an escrow contract but has not allowed sending "AGGREGATE" transactions
    Given Alice defined a valid escrow contract
    And "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And Alice only allowed sending "TRANSFER" transactions
    When she publishes the contract
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to create an escrow contract but has blocked sending "AGGREGATE" transactions
    Given Alice blocked sending "AGGREGATE" transactions
    And Alice defined a valid escrow contract
    And  "Alice" locked 10 "xem" to guarantee that the contract will conclude in less than 2 days
    When she publishes the contract
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"
