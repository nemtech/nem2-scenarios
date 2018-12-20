Feature: Create a multisignature contract
  As Alice,
  I want to create a multisignature contract between my phone and my computer,
  so that I have multi factor-authentication.

  Background:
    Given the maximum number of cosignatories per multisignature contract is 10
    And the maximum number of multisignature contracts an account can be cosignatory of is 5

  Scenario Outline: An account creates an M-of-N contract
    When Alice creates a <minimumApproval> of 2 multisignature contract
    And she adds the following cosignatories:
      | cosignatory|
      | phone      |
      | computer   |
    Then she should receive a confirmation message
    And <minimumApproval> of the cosignatories is required to announce transactions from her account

    Examples:
      | minimumApproval |
      | 1               |
      | 2               |
      | 30              |

  Scenario: An account tries to create an N-of-M contract
    When Alice creates a 2 of 1 multisignature contract
    Then she should receive the error "Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories"

  Scenario: An account tries to create an (-M)-of-N contract
    When Alice defines a -1 of 2 multisignature contract
    And she should receive the error "Failure_Multisig_Modify_Min_Setting_Out_Of_Range"

  Scenario Outline: An account tries to create a multisignature contract, setting an invalid minimum of cosignatures to remove a cosignatory
    When Alice defines a 1 of 2 multisignature contract
    And she adds the following cosignatories:
      | cosignatory|
      | phone      |
      | computer   |
    And sets <minimum-removal> as the minimum number of required cosignatures to remove a cosignatory from the multisignature contract
    Then she should receive the error "<error>"

    Examples:
      | minimum-removal | error                                                             |
      | 0               | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | -1              | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | 3               | Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories |

  Scenario: An account tries to create a multisignature contract adding twice the same cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And she adds the following cosignatories:
      | cosignatory|
      | phone      |
      | phone      |
    Then she should receive the error "Failure_Multisig_Modify_Redundant_Modifications"

  Scenario: An account tries to create a multisignature contract with more than 10 cosignatories
    When Alice defines a 1 of 11 multisignature contract
    And she adds 11 cosignatories
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigners"

  Scenario: An account tries to add as a cosignatory an account which is already cosignatory of 5 multisignature contracts
    Given Bob is cosignatory of 5 multisignature contracts
    When Alice defines a 1 of 1 multisignature contract
    And she adds "Bob" as a cosignatory
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigned_Accounts"

  Scenario: An account tries to create a multisignature contract adding itself as a cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And she adds "Alice" as a cosignatory
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract, adding a multisig cosignatory where the account is a cosignatory.
    Given Alice is cosignatory of a deposit multisignature contract
    When Alice defines a 1 of 1 multisignature contract
    And she adds "deposit" as a cosignatory
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract deleting a cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And she adds "phone" as a cosignatory
    And she deletes "carol" from the cosignatories
    Then she should receive the error "Failure_Multisig_Modify_Unknown_Multisig_Account"

  Scenario: An account creates a multi-level multisignature contract
    Given Alice has created a multisignature contract
    When she adds a new multisignature contract cosignatory
    Then the multisignature contract should become a 2 level multisig contract

  Scenario: An account tries to create a multisignature contract with four levels of nested multisignature contracts
    Given Alice has created a multisignature with three levels of multisig cosignatories
    When she adds a new multisignature contract cosignatory to the third level
    Then she should receive the error "Failure_Multisig_Modify_Unknown_Multisig_Account"

  # Todo: Failure_Multisig_Modify_Unsupported_Modification_Type
