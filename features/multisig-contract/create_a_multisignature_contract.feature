Feature: Create a multisignature contract
  As Alice,
  I want to create a multisignature contract between my phone and my computer,
  so that I have multi factor-authentication.

  Background:
    Given the maximum number of cosignatories per multisignature contract is 10
    And the maximum number of multisignature contracts an account can be cosignatory of is 5

  Scenario: An account creates an M-of-N contract
    When Alice defines a 1 of 2 multisignature contract
    And she adds "phone" as a cosignatory
    And she adds "computer" as a cosignatory
    And publishes the contract
    Then she should receive a confirmation message
    And she should not be able to announce transactions from her account
    And her "phone" or "computer" cosignature should be required to announce transactions from her account

  Scenario: An account creates an N-of-N contract
    When Alice defines a 2 of 2 multisignature contract
    And she adds "phone" as a cosignatory
    And she adds "computer" as a cosignatory
    And publishes the contract
    Then she should receive a confirmation message
    And she should not be able to announce transactions from her account
    And her "phone" and "computer" cosignatures should be required to announce transactions from her account

  Scenario: An account tries to create an N-of-M contract
    When Alice defines a 2 of 1 multisignature contract
    And adds "phone" as a cosignatory
    And adds "computer" as a cosignatory
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories"

  Scenario: An account tries to create an (-M)-of-N contract
    When Alice defines a -1 of 2 multisignature contract
    And she adds "phone" as a cosignatory
    And she adds "computer" as a cosignatory
    And publishes the contract
    Then she should not be able to announce transactions from her account
    And she should receive the error "Failure_Multisig_Modify_Min_Setting_Out_Of_Range"

  Scenario Outline: An account tries to create a multisignature contract, setting an invalid minimum of cosignatures to remove a cosignatory
    When Alice defines a 1 of 2 multisignature contract
    And she adds "phone" as a cosignatory
    And she adds "computer" as a cosignatory
    And sets <minimum-removal> as the minimum number of required cosignatures to remove a cosignatory from the multisignature contract
    And publishes the contract
    Then she should receive the error "<error>"

    Examples:
      | minimum-removal | error                                                             |
      | 0               | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | -1              | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | 3               | Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories |

  Scenario: An account tries to create a multisignature contract adding twice the same cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And she adds "phone" as a cosignatory
    And she adds "phone" as a cosignatory
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Redundant_Modifications"

  Scenario: An account tries to create a multisignature contract with more than 10 cosignatories
    When Alice defines a 1 of 11 multisignature contract
    And she adds 11 cosignatories
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigners"

  Scenario: An account tries to add as a cosignatory an account which is already cosignatory of 5 multisignature contracts
    Given Bob is cosignatory of 5 multisignature contracts
    When Alice defines a 1 of 1 multisignature contract
    And adds "bob" as a cosignatory
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigned_Accounts"

  Scenario: An account tries to create a multisignature contract adding itself as a cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And she adds "alice" as a cosignatory
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract, adding a multisig cosignatory where the account is a cosignatory.
    Given Alice is cosignatory of a deposit multisignature contract
    When Alice defines a 1 of 1 multisignature contract
    And she adds "deposit" as a cosignatory
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract deleting a cosignatory
    When Alice defines a 1 of 1 multisignature contract
    And adds "phone" as a cosignatory
    And deletes "carol" from the cosignatories
    And publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Unknown_Multisig_Account"

  # To do: Failure_Multisig_Modify_Unsupported_Modification_Type
