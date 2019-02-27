Feature: Announce a transaction
  As Alice,
  I want to announce a transaction
  So that I can alter the state of the blockchain

  Background:
    Given Alice has an account in MAIN_NET
    And the maximum transaction lifetime is 1 day

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
      | deadline | error                         |
      | 25       | Failure_Core_Future_Deadline  |
      | 999      | Failure_Core_Future_Deadline  |
      | 0        | Failure_Core_Past_Deadline    |
      | -1       | Failure_Core_Past_Deadline    |

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

#Fee Behaviour
  Scenario: An account announced a valid transaction
    Given Alice announced a valid transaction to the "MAIN_NET"
    When the transaction status is Success
    Then her "nem:xem" balance is the deducted by the "transaction_fee"

  Scenario Outline: An account announced a transaction with an invalid deadline
    Given Alice announced a transaction with a deadline of <deadline> hours
    When Alice announces the transaction to a "MAIN_NET" node
    And the transaction status is Failed due to the error "<error>"
    Then the "transaction_fee" is not deducted from her "nem:xem" balance

    Examples:
      | deadline | error                        |
      | 25       | Failure_Core_Future_Deadline |
      | 999      | Failure_Core_Future_Deadline |
      | 0        | Failure_Core_Past_Deadline   |
      | -1       | Failure_Core_Past_Deadline   |

  Scenario: An account announced a transaction with an expired deadline
    Given Alice announced 3 hours ago a transaction with a deadline of 2 hours to the "MAIN_NET"
    When Alice announces the transaction to a "MAIN_NET" node
    And the transaction status is Failed due to error "Failure_Core_Past_Deadline"
    Then the "transaction_fee" will not be deducted from her "nem:xem" balance

  Scenario: An expired deadline on unconfirmed transaction
    Given Alice announced a valid transaction
    And the deadline expired in its unconfirmed state
    When the transaction status is Success
    Then a "transaction fee" is deducted from her "nem:xem" balance

  Scenario: An account announced a transaction with an invalid signature
    Given Alice annouced a transaction using an invalid or random signature
    When Alice announces the transaction to any "MAIN_NET" node
    And the transaction status is Failed due to error "Failure_Signature_Not_Verifiable"
    Then Alice shall not be charged the "transaction_fee" for announcing a transaction.

  Scenario: An account announced an already announced transaction
    Given Alice announced a transaction using a pre existing transaction hash
    When Alice announces an already announced transaction to a "MAIN_NET" node
    And the transaction status is Failed due to error "Failure_Hash_Exists"
    Then Alice shall not be charged a "transaction_fee"
    And her "nem:xem" balance shall stay intact

  Scenario: An account announced a transaction with an invalid network
    Given Alice defined a transaction on the "TEST_NET"
    And announced the transaction on the "MAIN_NET"
    When Alice announces a transaction on a different network than what was defined
    And the transaction status is Failed due to error "Failure_Core_Wrong_Network"
    Then Alice's "nem:xem" balance stays intact

  Scenario: A nemesis account announced a transaction
    Given Alice is a nemesis account
    When Alice announced a valid transaction to the "MAIN_NET"
    And the transaction status is Failed due to error "Failure_Core_Nemesis_Account_Signed_After_Nemesis_Block"
    Then Alice is not charged a "transaction_fee"
    And her "nem:xem" balanced is intact

  Scenario: Multisig contract announced a transaction
    Given Alice is a multisig contract
    When Alice announced a valid transaction to a "MAIN_NET" node
    And the transaction status is Failed due to error "Failure_Multisig_Operation_Not_Permitted_By_Account"
    Then Alice does not pay a "transaction_fee"
    And her "nem:xem" balance is intact

# Status errors not treated:
# - Failure_Core_Too_Many_Transactions

#Receipt Behavior
# Transaction_Group receipt
  Scenario: Alice wants to get the state change of transaction
    Given Alice sends a valid transaction to the "MAIN_NET" node
    When Alice wants to get the state change of the her Transfer transaction
    Then Alice should get the "confirmed" status of the Transfer transaction
