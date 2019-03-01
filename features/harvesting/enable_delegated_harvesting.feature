Feature: Enable delegated harvesting
  As Alice
  I want to enable delegated harvesting
  So that I can share my importance with a remote node securely to harvest new blocks.

  Scenario: An account enables delegated harvesting and delegates its importance to a remote account
    When she enables delegated harvesting delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive a confirmation message
    And the delegate account can use Alice's importance to harvest

  Scenario: An account disables delegated harvesting
    Given Alice delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she disables delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive a confirmation message
    And the delegate account can not use Alice's importance to harvest

  Scenario: An account tries to enable delegated harvesting twice
    Given Alice delegated his importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she enables delegated harvesting delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_AccountLink_Link_Already_Exists"

  Scenario: An account tries to disable delegated harvesting but it was not enabled
    When she disables delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_AccountLink_Link_Does_Not_Exist"

  Scenario: An account tries to enable delegated harvesting but the remote account was already linked
    Given Bob delegated his importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she enables delegated harvesting delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_AccountLink_Remote_Account_Ineligible"

  Scenario: An account tries to disable delegated harvesting from another account
    Given Bob has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she disables delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then Alice should receive the error "Failure_AccountLink_Unlink_Data_Inconsistency"

  Scenario: A remote account tries to sign a transaction
    Given Alice has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE" announces a transaction
    Then "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE" should receive the error "Failure_AccountLink_Remote_Account_Signer_Not_Allowed"

  Scenario: A remote account participates in an escrow contract
    Given Alice has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When Alice adds "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE" as a participant of an escrow contract
    Then Alice should receive the error "Failure_AccountLink_Remote_Account_Participant_Not_Allowed"

  Scenario: An account tries to enable delegated harvesting but has not allowed sending "ACCOUNT_LINK" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    When she enables delegated harvesting delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to enable delegated harvesting but has blocked sending "ACCOUNT_LINK" transactions
    Given Alice blocked sending "ACCOUNT_LINK" transactions
    And Alice has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she enables delegated harvesting delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to disable delegated harvesting but has not allowed sending "ACCOUNT_LINK" transactions
    Given Alice has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    And Alice only allowed sending "TRANSFER" transactions
    When she disables delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  Scenario: An account tries to disable delegated harvesting but has blocked sending "ACCOUNT_LINK" transactions
    Given Alice has delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    And Alice blocked sending "ACCOUNT_LINK" transactions
    When she disables delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    Then she should receive the error "Failure_Property_Transaction_Type_Not_Allowed"

  # Status errors not treated:
  # Failure_AccountLink_Invalid_Action

  # Receipt Behavior
  Scenario: Alice wants to see if she delegated its importance to a remote account
    Given Alice enabled delegated harvesting her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When Alice wants to see if the delegate account can use her importance to harvest
    Then Alice should see if the delegated account can use her importance to harvest

  Scenario: Alice wants to see if she disabled delegated harvesting to a remote account
    Given Alice delegated her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    And she disabled delegating her account importance to "54BEF898980B8C4EBF81894775994FB0255BA4D5926126865FBA544360A0FDEE"
    When she wants to see if the delegated account has been disabled
    Then Alice should see if the delegated account has been disabled
