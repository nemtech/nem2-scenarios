Feature: Accept an escrow contract
  As Alice,
  I want to accept an escrow contract,
  so that I give my explicit approval to change my account state.

  Background:
    Given an escrow contract is active up to 2 days
    And the mean block generation time is 15 seconds

  Scenario: An escrow contract concludes
    Given Bob has asked Alice for 20 xem
    And "Alice" has 20 "xem"
    And Bob locked 10 "xem" to guarantee that the contract concludes in less than 2 days
    When Alice accepts it
    Then every sender participant should receive a confirmation notification
    And "Bob" should receive 30 "xem"
    And "Alice" "xem" balance should have decreased in 20 units

  Scenario: An escrow contract concludes and the future state makes the swap possible
    Given Alice does not have any euros
    And "Bob" has 1 "concert.ticket"
    And "Carol" has 20 "euros"
    And the following contract is pending to be accepted by Bob:
      | sender | recipient | type          | data            |
      | Alice  | Bob       | send-an-asset | 18 euros        |
      | Bob    | Alice     | send-an-asset | 1 concert.ticket|
      | Carol  | Alice     | send-an-asset | 20 euros        |
    When every sender participant accepts it
    Then every sender participant should receive a confirmation notification
    And "Bob" should receive 20 "euros"
    And "Alice" should receive 1 "concert.ticket"
    And "Alice" should have 2 "euros"
    And "Carol" "xem" balance should have decreased in 20 units

  Scenario: An account accepts an escrow contract but not all participants have accepted it
    Given Bob has asked Alice and Carol for 20 xem
    And Bob locked 10 "xem" to guarantee that the contract concludes in less than 2 days
    And Alice accepted the escrow contract
    Then Carol should accept the escrow contract
    And Alice xem balance should have not decreased

  Scenario: An account required to accept the escrow contract is a multisiginature contract
    Given every sender participant who was notified to accept an escrow contract has accepted it except Alice
    And "Alice" is a 2 of 2 multisignature contract with the following cosignatories:
      |cosignatories|
      | phone       |
      | computer    |
    When Alice accepts it with both participants
    Then every sender participant should receive a confirmation notification

  Scenario: An account required to accept the escrow contract is a multi-level multisiginature contract
    Given every sender participant who was notified to accept an escrow contract has accepted it except Alice
    And "Alice" is a 2 of 2 multisignature contract with the following cosignatories:
      |cosignatories|
      | phone       |
      | computer    |
    And "Computer" is a 1 of 2 multisignature contract with the following cosignatories:
      |cosignatories|
      | nemapp      |
      | nembrowser  |
    When "phone" accepts it
    And "nemapp" accepts it
    And "nembrowser" accepts it
    Then every sender participant should receive a confirmation notification

  Scenario: Every sender participant has accepted the contract but this presents some validation error
    Given Alice does not own 1 concert.ticket
    And the following contract is pending to be accepted by Bob:
      | sender | recipient | type          | data            |
      | Alice  | Bob       | send-an-asset | 1 concert.ticket|
      | Bob    | Alice     | send-an-asset | 20 euros        |
    When "Bob" accepts it
    Then every sender participant should receive the error "Failure_Core_Insufficient_Balance"
    And every sender participant balance should remain intact

  Scenario: An account tries to accept an escrow contract that the account has already accepted
    Given Alice has created and escrow contract that has not concluded yet
    When she signs it again
    Then every sender participant should receive the error "Failure_Aggregate_Redundant_Cosignatures"

  Scenario: An account not required to accept the escrow contract accepts it
    Given Bob and Carol have an escrow contract pending to be accepted
    When Alice accepts it
    Then every sender participant should receive the error "Failure_Aggregate_Ineligible_Cosigners"

  Scenario: An account tries to accept a concluded escrow contract
    Given an escrow contract has concluded successfully
    When Alice accepts it
    Then she should receive the error "Failure_Lock_Inactive_Hash"

  Scenario: An account tries to accept an expired escrow contract
    Given an escrow contract has expired
    When Alice accepts it
    Then she should receive the error "Failure_Lock_Inactive_Hash"
