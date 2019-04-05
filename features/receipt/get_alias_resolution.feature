Feature: Get the alias resolution for a given transaction
  As Alice
  I want to get the real identifier of the account or asset used in a transaction

  # Core
  Scenario: An account tries to get the address of an aliased recipient in a given transaction
    Given "Alice" sent 1 "event.organizer" to "ticket_vendor"
    When "Alice" wants to get the recipient address for the previous transaction
    Then "Alice" should get "SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5"

  Scenario: Alice wants to get the identifier of the aliased asset used in a given transaction
    Given "Alice" sent 1 "event.organizer" to "ticket_vendor"
    When "Alice" wants to get "event.organizer" identifier  for the previous transaction
    Then "Alice" should get "0dc67fbe1cad29e5"
