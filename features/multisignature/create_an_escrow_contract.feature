Feature: Create an escrow contract
  As Alice,
  I want to create an escrow contract between different participants,
  so that there is no need to trust in each other.

  Background:
    Given the maximum number of participants per escrow contract is 15
    And the maximum number of transactions per escrow contract is 1000
    And each escrow contract requires to lock at least 10 "xem" to guarantee that the contract will conclude
    And an escrow contract is active up to 2 days
    And a contract concludes when all the involved cosignatories have signed it

  Scenario: An account creates an escrow contract
    When Alice defines an escrow contract
    And she states that "Alice" will send 1 "concert.ticket" to "Bob"
    And she states that "Bob" will send 20 "euros" to "Alice"
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive a confirmation message
    And "Bob" should receive a notification informing it's cosignature is required

  Scenario: An account creates an escrow contract adding a new participant
    Given Exchange is a multisig contract
    When Alice defines an escrow contract
    And she states that "Alice" will send 1 "concert.ticket" to "Bob"
    And she states that "Bob" will send 20 "xem" to "Exchange"
    And she states that "Exchange" will send 20 "euros" to "Alice"
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive a confirmation message
    And "Bob" should receive a notification informing it's cosignature is required
    And "Exchange" should receive a notification informing it's cosignature is required

  Scenario: An account creates an escrow contract with multiple types of transactions
    When Alice defines an escrow contract
    And she states that "Alice" will register the namespace "alice"
    And she states that "Bob" will create a multisig contract adding her as a cosignatory
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive a confirmation message
    And "Bob" should receive a notification informing it's cosignature is required

  Scenario: An account creates an escrow contract and another account locks the funds for that contract
    When Alice defines an escrow contract
    And she states that "Alice" will register the namespace "alice"
    And she states that "Bob" will create a multisig contract adding her as a cosignatory
    And Bob locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive a confirmation message
    And "Bob" should receive a notification informing it's cosignature is required

  Scenario: An account creates an escrow contract locking more than 10 xem for that contract
    Given Alice defined a valid escrow contract
    And Alice locks 11 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive a confirmation message

  Scenario: An account tries to create an escrow contract with too many transactions
    When Alice defines an escrow contract involving more than 1000 transactions
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive the error "Failure_Aggregate_Too_Many_Transactions"

  Scenario: An account tries to create an escrow contract with too many different cosignatories
    When Alice defines an escrow contract involving 16 different accounts
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive the error "Failure_Aggregate_Too_Many_Cosignatures"

  Scenario: An account tries to create an empty escrow contract
    When Alice defines an escrow contract
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive the error "Failure_Aggregate_No_Transactions"

  Scenario: An account tries to create an escrow contract inside an escrow contract
    When Alice defines an escrow contract inside an escrow contract
    And she states that "Bob" will turn his account into multisig adding her as a cosignatory
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive an error "Not possible to nest aggregate transactions"

  Scenario: An account tries to create an escrow contract but the account will not do any transaction
    When Alice defines an escrow contract
    And she states that "Bob" will turn his account into multisig adding her as a cosignatory
    And she locks 10 "xem" to guarantee that the contract will conclude in less than 2 days
    And she publishes the contract
    Then Alice should receive the error "Failure_Aggregate_Ineligible_Cosigners"

  Scenario: An account tries to create an escrow contract but the lock expired
    Given Alice defined a valid escrow contract
    And locked 10 "xem" three days ago for that contract
    When she publishes the contract
    Then Alice should receive the error "Failure_Lock_Inactive_Hash"

  Scenario: An account tries to create an escrow contract but the lock already exists
    Given Alice locked 10 "xem" to publish an escrow
    And  she locks 10 "xem" for the same escrow
    Then Alice should receive the error "Failure_Lock_Hash_Exists"

  Scenario: An account tries to create an escrow without locking funds in advance
    Given Alice defined a valid escrow contract
    When she publishes the contract
    Then Alice should receive the error "Failure_Lock_Hash_Does_Not_Exist"

  Scenario: An account tries to create an escrow but locks another mosaic that is not xem
    Given Alice defined a valid escrow contract
    When Alice locks 10 "tickets" to guarantee that the contract will conclude in less than 2 days
    Then Alice should receive the error "Failure_Lock_Invalid_Mosaic_Id"
    And her xem balance should remain intact

  Scenario: An account tries to create an escrow an escrow but locks less than 10 xem
    Given Alice defined a valid escrow contract
    When Alice locks 9 "xem" to guarantee that the contract will conclude in less than 2 days
    Then Alice should receive the error "Failure_Lock_Invalid_Mosaic_Amount"
    And her xem balance should remain intact

  Scenario Outline: An account tries to create an escrow but sets an invalid duration
    Given Alice defined a valid escrow contract
    When Alice locks 10 "xem" to guarantee that the contract will conclude in less than <duration> days
    Then Alice should receive the error "Failure_Lock_Invalid_Duration"
    And her xem balance should remain intact

    Examples:
      |duration|
      | -1     |
      | 0      |
      | 3      |

# Todo: Failure_Aggregate_Redundant_Cosignatures
