Feature: Send a message
  As Alice
  I want to send a message to Bob
  So that there is evidence that I have sent the message.

  Background:
    Given the mean block generation time is 15 seconds
    And the maximum message length is 1024

  Scenario Outline: An account sends a message to another account

    When Alice sends "<message>" to "<recipient>"
    Then she should receive a confirmation message
    And the "<recipient>" should receive the message "<message>"

    Examples:
      | message | recipient                                      |
      | Hello   | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 |
      | Hello   | Bob                                            |

  Scenario Outline: An account tries to send a message to an invalid account

    When Alice sends "<message>" to "<recipient>"
    Then she should receive the error "<error>"

    Examples:
      | message | recipient                                      | error                        |
      | Hello   | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | Failure_Core_Invalid_Address |
      | Hello   | bo                                             | Failure_Core_Invalid_Address |
      | Hello   | MAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Wrong_Network   |

  Scenario: An account  tries to send a message to another account but the message is too large

    When Alice sends a really long message to Bob
    Then she should receive the error "Failure_Transfer_Message_Too_Large"

  Scenario: An account sends an encrypted message to another account

    When Alice sends the encrypted message "Hello" to "Bob"
    Then she should receive a confirmation message
    And Bob should receive the encrypted message
    And he should be the only one capable of reading the original message

  Scenario: An account tries to send an message to another account but has not allowed sending "TRANSFER" transactions
    Given Alice only allowed sending "REGISTER_NAMESPACE" transactions
    When "Alice" sends "Hello" to "Bob"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to send a message to another account but has blocked sending "TRANSFER" transactions
    Given Alice blocked sending "TRANSFER" transactions
    When "Alice" sends "Hello" to "Bob"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to send a message to another account but the second account does not allow it
    Given Bob only allowed receiving transactions from Carol
    When "Alice" sends "Hello" to "Bob"
    Then she should receive the error "Failure_Property_Signer_Address_Interaction_Not_Allowed"

  Scenario: An account tries to send a message to another account but the second account blocked it
    Given Bob blocked receiving transactions from Alice
    When "Alice" sends "Hello" to "Bob"
    Then she should receive the error "Failure_Property_Signer_Address_Interaction_Not_Allowed"
