Feature: Announce a transaction
  As Alice,
  I want to announce a transaction
  So that I can alter the state of the blockchain

  Background:
    Given Alice has an account in MAIN_NET
    And the maximum transaction lifetime is 1 day
    And the native currency mosaic is "xem"

  Scenario: Alice announces a valid transaction
    Given Alice defined a valid transaction
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive a confirmation message

  Scenario Outline: An account tries to announce a transaction with an invalid deadline
    Given Alice defined a transaction with a deadline of <deadline> hours
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "<error>"

    Examples:
      | deadline | error                        |
      | 25       | Failure_Core_Future_Deadline |
      | 999      | Failure_Core_Future_Deadline |
      | 0        | Failure_Core_Past_Deadline   |
      | -1       | Failure_Core_Past_Deadline   |

  Scenario: An account tries to announce a transaction with an expired deadline
    Given Alice defined 3 hours ago a transaction with a deadline of 2 hours
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Past_Deadline"

  Scenario: An unconfirmed transaction deadline expires
    Given Alice announces a valid transaction
    When the transaction deadline expires while the transaction has unconfirmed status
    Then she should receive a confirmation message

  Scenario: An account tries to announce a transaction with an invalid signature
    Given Alice defined a random transaction signature
    And she announces the transaction to a "MAIN_NET" node
    Then She should receive the error "Failure_Signature_Not_Verifiable"

  Scenario: An account tries to announce an already announced transaction
    Given Alice defined a valid transaction
    And she signed the transaction
    And she announced the transaction to a "MAIN_NET" node
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Hash_Exists"

  Scenario: An account tries to announce a transaction with an invalid network
    Given Alice defined a transaction with network "TEST_NET"
    And she signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Wrong_Network"

  Scenario: The nemesis account tries to announce a transaction
    Given Alice is the nemesis account
    And Alice defined a valid transaction
    And Alice signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Core_Nemesis_Account_Signed_After_Nemesis_Block"

  Scenario: A multisig contract tries to announce a transaction
    Given Alice is a multisig contract
    And Alice defined a valid transaction
    And Alice signed the transaction
    When Alice announces the transaction to a "MAIN_NET" node
    Then she should receive the error "Failure_Multisig_Operation_Not_Permitted_By_Account"

  Scenario: An account announced a valid transaction
    Given Alice announced a valid transaction of size 10 bytes
    And sets a "max_fee" of 25 "xem"
    When a node with a fee multiplier of 2 processes the transaction 
    Then the node accepts the transaction 
    And her "xem" balance is deducted by 20 units

  Scenario: An account announced a valid transaction and sets max fee too low
    Given Alice announced a valid transaction of size 10 bytes
    And sets a "max_fee" of 10 "xem"
    When a node with a fee multiplier of 2 processes the transaction 
    Then the node rejects the transaction 
    And her "xem" balance stays intact

  Scenario: valid transaction not accepted by any node due to low max fee
    Given Alice announced a valid transaction of size 10 bytes
    And sets a "max_fee" of 5 "xem"
    And transaction is not accepted by any node with a fee multiplier of 2
    When the transaction deadline is reached
    Then the transaction is dropped
    And her "xem" balance stays intact

  # Status errors not treated:
  # - Failure_Core_Too_Many_Transactions
