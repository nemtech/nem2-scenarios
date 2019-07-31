@not-implemented
Feature: Edit a multisignature contract
  As Alice,
  I want to edit a multisignature contract,
  so that I have multi-factor authentication up-to-date.

  Background:
    Given the maximum number of cosignatories per multisignature contract is 10
    And the maximum number of multisignature contracts an account can be cosignatory of is 5
    And  multisignature contracts created have set the minimum number of cosignatures to remove a cosignatory to 1

  Scenario: A cosignatory adds another cosignatory to the multisignature contract
    Given Alice created the following 1 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    When "computer" adds the following cosignatories to the multisignature:
      | cosignatory |
      | tablet      |
    Then "Alice" should receive a confirmation message
    And "tablet" is a cosignatory of the multisignature contract

  Scenario: A cosignatory accepts the addition of another cosignatory to the multisignature contract
    Given Alice created the following 2 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    And "computer" proposed adding "tablet" as a multisignature cosignatory
    When "phone" accepts the addition
    Then "Alice" should receive a confirmation message
    And "tablet" is a cosignatory of the multisignature contract

  Scenario: A cosignatory account removes another cosignatory from the multisignature contract
    Given Alice created the following 2 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    When "computer" removes "phone" from the multisignature cosignatories
    Then "Alice" should receive a confirmation message
    And "phone" is not a cosignatory of the multisignature contract
    And the multisignature contract still requires "computer" signature

  Scenario: A cosignatory account removes itself from the multisignature contract
    Given Alice created the following 2 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    When "computer" removes "computer" from the multisignature cosignatories
    Then "Alice" should receive a confirmation message
    And "computer" is not a cosignatory of the multisignature contract

  Scenario: A cosignatory account accepts removing another cosignatory from the multisignature contract
    Given Alice created the following 2 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    And the minimum number of cosignatures to remove a cosignatory was set to 2
    And "computer" proposed to remove "tablet" as a multisignature cosignatory
    When "phone" accepts the removal
    Then "Alice" should receive a confirmation message
    And "phone" is not a cosignatory of the multisignature contract
    And the multisignature contract still requires "computer" signature

  Scenario: All cosignatories are removed from the multisignature contract
    Given Alice created the following 1 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    When "computer" removes all cosignatories
    Then "Alice" should receive a confirmation message
    And the multisignature contract should become a regular account

  Scenario Outline: A cosignatory tries to set an invalid minimum of cosignatures to approve a transaction
    Given Alice created the following 1 of 2 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" increases the minimum number of cosignatures to approve a transaction in <minimum-approval> units
    Then "Alice" should receive the error "<error>"

    Examples:
      | minimum-approval | error                                                             |
      | -1               | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | -2               | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | 2                | Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories |

  Scenario Outline: A cosignatory tries to set an invalid minimum of cosignatures to remove a cosignatory
    Given Alice created the following 1 of 2 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" increases the minimum number of cosignatures to remove a cosignatory in <minimum-removal> units
    Then "Alice" should receive the error "<error>"

    Examples:
      | minimum-removal | error                                                             |
      | -1              | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | -2              | Failure_Multisig_Modify_Min_Setting_Out_Of_Range                  |
      | 2               | Failure_Multisig_Modify_Min_Setting_Larger_Than_Num_Cosignatories |

  Scenario: A cosignatory tries adding twice another cosignatory to the multisignature contract
    Given Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds "<phone>" as a cosignatory of the multisignature
    Then "Alice" should receive the error "Failure_Multisig_Modify_Already_A_Cosigner"

  Scenario: A cosignatory tries adding twice another cosignatory to the multisignature contract in the same transaction
    Given Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds the following cosignatories to the multisignature:
      | cosignatory |
      | tablet      |
      | tablet      |
    Then "Alice" should receive the error "Failure_Multisig_Modify_Redundant_Modifications"

  Scenario: A cosignatory tries to add more than 10 cosignatories to the multisignature contract
    Given Alice created a 1 of 10 multisignature contract
    When "a cosigner" adds "tablet" as a cosignatory of the multisignature
    Then "Alice" should receive the error "Failure_Multisig_Modify_Max_Cosigners"

  Scenario: A cosignatory tries to add a cosignatory which is already cosignatory of 5 multisignature contracts
    Given Bob is cosignatory of 5 multisignature contracts
    And Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds "Bob" as a cosignatory of the multisignature
    Then "Alice" should receive the error "Failure_Multisig_Modify_Max_Cosigned_Accounts"

  Scenario: A cosignatory tries to add the multisignature contract as a cosignatory
    And Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds "Alice" as a cosignatory of the multisignature
    Then "Alice" should receive the error "Failure_Multisig_Modify_Loop"

  Scenario: A cosignatory tries to add another cosignatory where the multisignature contract is a cosignatory.
    Given Alice is cosignatory of a deposit multisignature contract
    And Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds "deposit" as a cosignatory of the multisignature
    Then "Alice" should receive the error "Failure_Multisig_Modify_Loop"

  Scenario Outline: A cosignatory adds another cosignatory using an invalid address
    Given Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds "<address>" as a cosignatory of the multisignature
    Then she should receive the error "<error>"

    Examples:
      | address                                        | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | Failure_Core_Invalid_Address |
      | LAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Wrong_Network   |

  Scenario: A cosignatory tries to delete multiple cosignatories
    Given Alice created the following 1 of 2 multisignature contract:
      | cosignatory |
      | phone       |
      | computer    |
    When "phone" removes all the cosignatories in the same transaction
    Then "Alice" should receive the error "Failure_Multisig_Modify_Multiple_Deletes"

  Scenario: A cosignatory tries to remove a cosignatory that does not exist
    Given Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" removes "tablet" from the multisignature contract
    Then "Alice" should receive the error "Failure_Multisig_Modify_Not_A_Cosigner"

  Scenario: A cosignatory tries to add and remove the same account as cosignatory at the same time
    Given Alice created the following 1 of 1 multisignature contract:
      | cosignatory |
      | phone       |
    When "phone" adds and removes "tablet" from the multisignature contract
    Then "Alice" should receive the error "Failure_Multisig_Modify_Account_In_Both_Sets"

  Scenario: An account tries to exceed three levels of nested multisignature contracts
    Given Alice has created a multisignature with three levels of multisignature cosignatories
    When she adds a new multisignature contract cosignatory to the third level
    Then she should receive the error "Failure_Multisig_Modify_Max_Multisig_Depth"

  # Account Restrictions
  Scenario: An account tries to edit a multisignature contract but has not allowed sending "MODIFY_MULTISIG_ACCOUNT" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice created a 1 of 1 multisignature contract
    When she adds "phone" as a cosignatory
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"

  Scenario: An account tries to edit a multisignature contract but has blocked sending "MODIFY_MULTISIG_ACCOUNT" transactions
    Given Alice blocked sending "MODIFY_MULTISIG_ACCOUNT" transactions
    And Alice created a 1 of 1 multisignature contract
    When she adds "phone" as a cosignatory
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"
