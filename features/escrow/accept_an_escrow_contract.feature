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
      | sender | recipient | type          | data             |
      | Alice  | Bob       | send-an-asset | 18 euros         |
      | Bob    | Alice     | send-an-asset | 1 concert.ticket |
      | Carol  | Alice     | send-an-asset | 20 euros         |
    When every sender participant accepts it
    Then every sender participant should receive a confirmation notification
    And the swap of assets should conclude

  Scenario: An account accepts an escrow contract but not all participants have accepted it
    Given Bob has asked Alice and Carol for 20 xem
    And Bob locked 10 "xem" to guarantee that the contract concludes in less than 2 days
    And Alice accepted the escrow contract
    Then Carol should accept the escrow contract
    And Alice xem balance should have not decreased

  Scenario: An account required to accept the escrow contract is a multisiginature contract
    Given every sender participant who was notified to accept an escrow contract has accepted it except Alice
    And "Alice" is a 2 of 2 multisignature contract with the following cosignatories:
      | cosignatories |
      | phone         |
      | computer      |
    When Alice accepts it with both participants
    Then every sender participant should receive a confirmation notification

  Scenario: An account required to accept the escrow contract is a multi-level multisiginature contract
    Given every sender participant who was notified to accept an escrow contract has accepted it except Alice
    And "Alice" is a 2 of 2 multisignature contract with the following cosignatories:
      | cosignatories |
      | phone         |
      | computer      |
    And "Computer" is a 1 of 2 multisignature contract with the following cosignatories:
      | cosignatories |
      | nemapp        |
      | nembrowser    |
    When "phone" accepts it
    And "nemapp" accepts it
    And "nembrowser" accepts it
    Then every sender participant should receive a confirmation notification

  Scenario: Every sender participant has accepted the contract but this presents some validation error
    # It applies to any restriction (e.g. Account properties filters)
    Given Alice does not own 1 concert.ticket
    And the following contract is pending to be accepted by Bob:
      | sender | recipient | type          | data             |
      | Alice  | Bob       | send-an-asset | 1 concert.ticket |
      | Bob    | Alice     | send-an-asset | 20 euros         |
    When "Bob" accepts it
    Then every sender participant should receive the error "Failure_Core_Insufficient_Balance"
    And every sender participant balance should remain intact

  Scenario: An account tries to accept an escrow contract that the account has already accepted
    Given Alice has created and escrow contract that has not concluded yet
    When Alice accepts it
    Then every sender participant should receive the error "Failure_Aggregate_Redundant_Cosignatures"

  Scenario: An account not required to accept the escrow contract accepts it
    Given Bob and Carol have an escrow contract pending to be accepted
    When Alice accepts it
    Then every sender participant should receive the error "Failure_Aggregate_Ineligible_Cosigners"

  Scenario: An account tries to accept a concluded escrow contract
    Given an escrow contract has concluded successfully
    When Alice accepts it
    Then she should receive the error "Failure_LockHash_Inactive_Hash"

  Scenario: An account tries to accept an expired escrow contract
    Given an escrow contract has expired
    When Alice accepts it
    Then she should receive the error "Failure_LockHash_Inactive_Hash"

  Scenario: Alice and Bob wants to see her xem balance after concluding escrow contract
    Given Alice sent Bob 20 "xem"
    And Bob locked 10 "xem" to guarantee the contract concludes in less than 2 days
    And Alice accepts it
    When Alice wants to see her "xem" balance after escrow contract concludes
    And Bob wants to see his "xem" balance
    Then Bob should find his "xem" balance increase by 30 units
    And Alice should find her "xem" balance decrease by 20 units

  Scenario: Alice and Bob wants to see they could make swaps of assets
    Given "Bob" has accepted the following contract:
      | sender | recipient | type          | data             |
      | Alice  | Bob       | send-an-asset | 18 euros         |
      | Bob    | Alice     | send-an-asset | 1 concert.ticket |
      | Carol  | Alice     | send-an-asset | 20 euros         |
    And Every sender participant has accepted it
    When Alice wants to check if swap of assets are possible
    Then Alice should be able to check that swap of assets should conclude

  Scenario: Alice wants to see if her xem balance decreased after accepting an escrow contract but not all participants accepted it
    Given Carol and Alice accepted the escrow contract
    And Bob locked 10 "xem" to guarantee tha the contract concludes in less than 2 days
    When Alice wants to check her xem balance after accepting escrow contract
    Then Alice should should see her xem balance has not decreased after accepting an escrow contract

  Scenario: Alice wants to check if every participant receive a confirmation after an multisig account accepts it
    Given "Alice" is a 2 fo 2 multisig contract with the following cosignatories:
      | cosignatories |
      | phone         |
      | computer      |
    And "Alice" accepted the escrow contract that required her acceptance
    And All participants have accepted the escrow contract
    When "Alice" wants to check if every participants received confirmation notification
    Then "Alice" should see that every participants have received confirmation notifcation

  Scenario: Alice wants to check if every participant receive a confirmation after a multi-level multisig account accepted it
    Given "Alice" is a 2 fo 2 multisig contract with the following cosignatories:
      | cosignatories |
      | phone         |
      | computer      |
    And "Computer" is a 1 of 2 multisig contract with the following cosignatories:
      | cosignatories |
      | nemapp        |
      | nembrowser    |
    And "phone" accepted the escrow contract
    And "nemapp" accepted the escrow contract
    And "nembrowser" accepted the escrow contract
    When "Alice" wants to check if every participants received confirmation notification
    Then "Alice" should see that every participants have received confirmation notifcation
