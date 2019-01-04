Feature: Create a multisignature contract
  As Alice,
  I want to create a multisignature contract between my phone and my computer,
  so that I have multi factor-authentication.

  Background:
    Given the maximum number of cosignatories per multisignature contract is 10
    And the maximum number of multisignature contracts an account can be cosignatory of is 5

  Scenario Outline: An account creates an M-of-N contract
    Given Alice defined a <minimumApproval> of 2 multisignature contract
    And she added the following cosignatories:
      | cosignatory|
      | phone      |
      | computer   |
    When she publishes the contract
    Then she should receive a confirmation message
    And <minimumApproval> of the cosignatories are required to announce transactions from her account

    Examples:
      | minimumApproval |
      | 1               |
      | 2               |
      | 30              |

  Scenario: An account tries to create an N-of-M contract
    Given Alice defined a 2 of 1 multisignature contract
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories"

  Scenario: An account tries to create an (-M)-of-N contract
    Given Alice defined a -1 of 2 multisignature contract
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Min_Setting_Out_Of_Range"

  Scenario Outline: An account tries to create a multisignature contract, setting an invalid minimum of cosignatures to remove a cosignatory
    Given Alice defined a 1 of 2 multisignature contract
    And she added the following cosignatories:
      | cosignatory|
      | phone      |
      | computer   |
    And set <minimum-removal> as the minimum number of required cosignatures to remove a cosignatory from the multisignature contract
    When she publishes the contract
    Then she should receive the error "<error>"

    Examples:
      | minimum-removal | error                                                             |
      | 0               | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | -1              | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | 3               | Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories |

  Scenario: An account tries to create a multisignature contract adding twice the same cosignatory
    Given Alice defined a 1 of 1 multisignature contract
    And she added the following cosignatories:
      | cosignatory|
      | phone      |
      | phone      |
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Redundant_Modifications"

  Scenario: An account tries to create a multisignature contract with more than 10 cosignatories
    Given Alice defined a 1 of 11 multisignature contract
    And she added 11 cosignatories
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigners"

  Scenario: An account tries to add as a cosignatory an account which is already cosignatory of 5 multisignature contracts
    Given Bob is cosignatory of 5 multisignature contracts
    And Alice defined a 1 of 1 multisignature contract
    And she added "Bob" as a cosignatory
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Max_Cosigned_Accounts"

  Scenario: An account tries to create a multisignature contract adding itself as a cosignatory
    Given Alice defined a 1 of 1 multisignature contract
    And she added "Alice" as a cosignatory
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract, adding a multisig cosignatory where the account is a cosignatory.
    Given Alice is cosignatory of a deposit multisignature contract
    And Alice defined a 1 of 1 multisignature contract
    And she added "deposit" as a cosignatory
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: An account tries to create a multisignature contract deleting a cosignatory
    Given Alice defined a 1 of 1 multisignature contract
    And she added "phone" as a cosignatory
    And she deleted "carol" from the cosignatories
    When she publishes the contract
    Then she should receive the error "Failure_Multisig_Modify_Unknown_Multisig_Account"

  Scenario Outline: An account tries to create a multisignature contract using an invalid address
    Given Alice defined a 1 of 1 multisignature contract
    And she added "<address>" as a cosignatory
    When she publishes the contract
    Then she should receive the error "<error>"

    Examples:
      |address                                        | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H | Failure_Core_Invalid_Address |
      | LAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5| Failure_Core_Wrong_Network   |

  Scenario: An account creates a multi-level multisignature contract
    Given Alice defined a multisignature contract
    When she adds a new multisignature contract cosignatory
    Then the multisignature contract should become a 2 level multisig contract

  Scenario: An account tries to create a multisignature contract with four levels of nested multisignature contracts
    Given Alice has created a multisignature with three levels of multisig cosignatories
    When she adds a new multisignature contract cosignatory to the third level
    Then she should receive the error "Failure_Multisig_Modify_Max_Multisig_Depth"

  Scenario: An account tries to create a multisig contract, but it has not allowed sending "MODIFY_MULTISIG_ACCOUNT" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice defined a 1 of 1 multisignature contract
    And she added "phone" as a cosignatory
    When she publishes the contract
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to create a multisig contract, but it has blocked sending "MODIFY_MULTISIG_ACCOUNT" transactions
    Given Alice blocked sending "MODIFY_MULTISIG_ACCOUNT" transactions
    And Alice defined a 1 of 1 multisignature contract
    And she added "phone" as a cosignatory
    When she publishes the contract
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"


  # Todo: Failure_Multisig_Modify_Unsupported_Modification_Type
