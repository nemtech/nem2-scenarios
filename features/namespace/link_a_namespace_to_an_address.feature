Feature: Link a namespace to an address
  As Alice,
  I want to link a namespace to an address,
  So that it is memorable and easily recognizable

  Scenario: An account links a namespace to an address
    Given Alice registered the namespace "bob"
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive a confirmation message
    And she should be able to send assets to "bob" instead of "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"

  Scenario: An account unlinks a namespace from an address
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the namespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive a confirmation message
    And she should not be able to send assets to "bob"

  Scenario: An account links a subnamespace to an address
    Given Alice registered the subnamespace "bob.account"
    When Alice links the subnamespace "bob.account" to the address "0dc67fbe1cad29e4"
    Then she should receive a confirmation message
    And she should be able to send assets to "bob.account" instead of "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"

  Scenario: An account unlinks a subnamespace from an address
    Given Alice linked the subnamespace "bob.account" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the subnamespace "bob.account" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive a confirmation message
    And she should not be able to send assets to "bob.account"

  Scenario: An account tries to link a namespace already in use (asset) to an address
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e4"
    When Alice links the namespace "token" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Already_Exists"

  Scenario: An account tries to link a namespace already in use (address) to an address
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Already_Exists"

  Scenario: An account tries to link an unknown namespace to an address
    When Alice links the namespace "unknown" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Namespace_Unknown"

  Scenario: An account tries to unlink an unknown namespace from an address
    When An account tries to unlink the namespace "unknown" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Namespace_Unknown"

  Scenario: An account tries to link a namespace she does not own to an address
    Given Bob registered the namespace "bob"
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: An account tries to unlink a namespace she does not own from an address
    Given Bob linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the namespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: An account tries to unlink an address link that does not exist
    Given Alice registered the namespace "bob"
    When Alice unlinks the namespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Does_Not_Exist"

  Scenario: An account tries to link a namespace to an address using the subnamespace type
    Given Alice registered the namespace "bob"
    When Alice links the subnamespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: An account tries to unlink a namespace from an address using the subnamespace type
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the subnamespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: An account tries to link a subnamespace to an address using the namespace type
    Given Alice registered the subnamespace "alice.bob"
    When Alice links the namespace "alice.bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: An account tries to unlink a subnamespace from an address using the namespace type
    Given Alice linked the subnamespace "alice.bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the namespace "alice.bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: An account tries to link a namespace to an address but uses an asset instead
    Given Alice registered the namespace "bob"
    When Alice links the namespace "bob" to the address "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Data_Inconsistency"

  Scenario: An account tries to unlink a namespace from an address but uses an asset instead
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice unlinks the namespace "bob" from the asset "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Data_Inconsistency"

  Scenario: An account tries to link a namespace to an address that does not exist in the network
    Given Alice registered the namespace "bob"
    And "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5" has not send or received any transaction
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Invalid_Address"

  Scenario Outline: An account tries to link a namespace to an invalid address
    Given Alice registered the namespace "bob"
    And Alice account is in "<network>"
    When Alice links the namespace "bob" to the address "<address>"
    Then she should receive the error "<error>"

    Examples:
      |network     | address                                        | error                         |
      | MIJIN_TEST | SAIBV5                                         | Failure_Core_Invalid_Address  |
      | MAIN_NET   | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Invalid_Network  |

  Scenario: An account tries to link a namespace to an address but has not allowed sending "ADDRESS_ALIAS" transactions
    Given Alice registered the namespace "bob"
    And Alice only allowed sending "TRANSFER" transactions
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to unlink a namespace from an address but has not allowed sending "ADDRESS_ALIAS" transactions
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    And Alice only allowed sending "TRANSFER" transactions
    When Alice unlinks the namespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to link a namespace to an address but has blocked sending "ADDRESS_ALIAS" transactions
    Given Alice registered the namespace "bob"
    And Alice blocked sending "ADDRESS_ALIAS" transactions
    When Alice links the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to unlink a namespace from an address but has blocked sending "ADDRESS_ALIAS" transactions
    Given Alice linked the namespace "bob" to the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    And Alice blocked sending "ADDRESS_ALIAS" transactions
    When Alice unlinks the namespace "bob" from the address "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"
