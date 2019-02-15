Feature: Link a namespace to an asset
  As Alice,
  I want to link a namespace to an asset,
  So that it is memorable and easily recognizable

  Scenario: Alice links a namespace to an asset
    Given Alice registered the namespace "token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive a confirmation message
    And she should be able to send "token" instead of "0dc67fbe1cad29e3" asset units

  Scenario: Alice unlinks a namespace from an asset
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive a confirmation message
    And she should not be able to send "token" asset units

  Scenario: Alice links a subnamespace to an asset
    Given Alice registered the subnamespace "alice.token"
    And she registered the asset "0dc67fbe1cad29e4"
    When Alice links the subnamespace "alice.token" to the asset "0dc67fbe1cad29e4"
    Then she should receive a confirmation message
    And she should be able to send "alice.token" instead of "0dc67fbe1cad29e4" asset units

  Scenario: Alice unlinks a subnamespace from an asset
    Given Alice linked the subnamespace "alice.token" to the asset "0dc67fbe1cad29e4"
    When Alice unlinks the subnamespace "alice.token" from the asset "0dc67fbe1cad29e3"
    Then she should receive a confirmation message
    And she should not be able to send "alice.token" asset units

  Scenario: Alice tries to link a namespace already in use (asset) to an asset
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e4"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Already_Exists"

  Scenario: Alice tries to link a namespace already in use (account) to an asset
    Given Alice linked the namespace "bob" to the asset "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    When Alice links the namespace "bob" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Already_Exists"

  Scenario: Alice tries to link a namespace twice to an asset
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Already_Exists"

  Scenario: Alice tries to link an unknown namespace to an asset
    When Alice links the namespace "unknown" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Namespace_Unknown"

  Scenario: Alice tries to unlink an unknown namespace from an asset
    When Alice tries to unlink the namespace "unknown" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Namespace_Unknown"

  # Todo: Check error
  Scenario: Alice tries to link a namespace to an unknown asset
    Given Alice registered the namespace "token"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "<error>"

  # Todo: Check error
  Scenario: Alice tries to unlink a namespace from an unknown asset
    When Alice links the namespace "unknown" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "<error>"

  Scenario: Alice tries to link a namespace to an asset that she does not own
    Given Alice registered the namespace "token"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: Alice tries to unlink a namespace from an asset that she does not own
    Given Alice registered the namespace "token"
    When Alice unlinks the namespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: Alice tries to link a namespace she does not own to an asset
    Given Bob registered the namespace "bob"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "bob" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: Alice tries to unlink a namespace she does not own from an asset
    Given Bob linked the namespace "coin" to the asset "0dc67fbe1cad29e4"
    When Alice unlinks the namespace "coin" from the asset "0dc67fbe1cad29e4"
    Then she should receive the error "Failure_Namespace_Alias_Owner_Conflict"

  Scenario: Alice tries to unlink an asset link that does not exist
    Given Alice registered the namespace "token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Does_Not_Exist"

  Scenario: Alice tries to link a namespace to an asset using the subnamespace type
    Given Alice registered the namespace "token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the subnamespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: Alice tries to unlink a namespace from an asset using the subnamespace type
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the subnamespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: Alice tries to link a subnamespace to an asset using the namespace type
    Given Alice registered the subnamespace "alice.token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "alice.token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: Alice tries to unlink a subnamespace from an asset using the namespace type
    Given Alice linked the subnamespace "alice.token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "alice.token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Type_Inconsistency"

  Scenario: Alice tries to link a namespace to an asset but uses an address instead
    Given Alice registered the namespace "token"
    When Alice links the namespace "token" to the asset "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Data_Inconsistency"

  Scenario: Alice tries to unlink a namespace from an asset but uses an address instead
    Given Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "token" from the address "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Namespace_Alias_Unlink_Data_Inconsistency"

  Scenario: An account tries to link a namespace to an asset but has not allowed sending "MOSAIC_ALIAS" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice registered the namespace "token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to unlink a namespace from an asset but has not allowed sending "MOSAIC_ALIAS" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to link a namespace to an asset but has blocked sending "MOSAIC_ALIAS" transactions
    Given Alice blocked sending "MOSAIC_ALIAS" transactions
    And Alice registered the namespace "token"
    And she registered the asset "0dc67fbe1cad29e3"
    When Alice links the namespace "token" to the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to unlink a namespace from an asset but has blocked sending "MOSAIC_ALIAS" transactions
    Given Alice blocked sending "MOSAIC_ALIAS" transactions
    And Alice linked the namespace "token" to the asset "0dc67fbe1cad29e3"
    When Alice unlinks the namespace "token" from the asset "0dc67fbe1cad29e3"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"
