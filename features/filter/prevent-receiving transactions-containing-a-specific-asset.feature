Feature: Prevent receiving transactions containing a specific asset
  As Alice,
  I only want to receive "cat.currency" assets
  So that I can ensure I don't own assets unrelated with my activity

  Background:
    Given the following assets are registered and active:
      | asset            |
      | ticket           |
      | voucher          |
      | cat.currency     |
    And an account can only define up to 512 mosaic filters

  Scenario: An account blocks receiving transactions containing a specific asset
    When Alice blocks receiving transactions containing the following assets:
      | asset   |
      | ticket  |
      | voucher |
    Then she should receive a confirmation message
    And receiving the stated assets should be blocked

  Scenario: An account allows only receiving transactions containing a specific asset
    When Alice only allows receiving transactions containing type:
      | asset          |
      | cat.currency   |
    Then she should receive a confirmation message
    And  receiving the stated assets should be allowed

  Scenario: An account unblocks an asset
    Given Alice blocked receiving transactions containing the following assets:
      | asset   |
      | ticket  |
      | voucher |
    When Alice unblocks "ticket"
    Then she should receive a confirmation message
    And receiving "voucher" assets should remain blocked

  Scenario: An account removes an asset from the allowed assets
    Given Alice only allowed receiving "ticket" assets
      | asset   |
      | ticket  |
      | voucher |
    When Alice removes "ticket" from the allowed assets
    Then she should receive a confirmation message
    And only receiving "voucher" assets should remain allowed

  Scenario: An account unblocks a not blocked asset
    Given Alice blocked receiving "ticket" assets
    When Alice unblocks "voucher"
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account removes an asset that does not exist in the allowed assets
    Given Alice blocked receiving "ticket" assets
    When Alice removes "voucher" from the allowed assets
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries only to allow receiving transactions containing specific assets when it has blocked assets
    Given Alice blocked receiving "ticket" assets
    When Alice only allows receiving "voucher" assets
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block receiving transactions containing specific assets when it has allowed assets
    Given Alice only allowed receiving "ticket" assets
    When Alice blocks receiving "voucher" assets
    Then she should receive the error "Failure_Property_Modification_Not_Allowed"

  Scenario: An account tries to block an asset twice
    Given Alice blocked receiving "ticket" assets
    When Alice blocks receiving "ticket" assets
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to allow an asset twice
    Given Alice only allowed receiving "ticket" assets
    When Alice only allows receiving "ticket" assets
    Then she should receive the error "Failure_Property_Modification_Redundant"

  Scenario: An account tries to block too many mosaics
    Given Alice blocked receiving 512 different assets
    When Alice blocks receiving "ticket" assets
    Then she should receive the error "Failure_Property_Values_Count_Exceeded"

  Scenario: An account tries to only allow too many mosaics
    Given Alice only allowed receiving 512 different assets
    When Alice only allows receiving "ticket" assets
    Then she should receive the error "Failure_Property_Values_Count_Exceeded"

  Scenario: An account tries to block too many mosaics in a single transaction
    When Alice blocks receiving 513 different assets
    Then she should receive the error "Failure_Property_Modification_Count_Exceeded"

  Scenario: An account tries to only allow too many mosaics in a single transaction
    When Alice only allows receiving 513 different assets
    Then she should receive the error "Failure_Property_Modification_Count_Exceeded"

  # Status errors not treated:
  # - Failure_Property_Invalid_Property_Type
  # - Failure_Property_Modification_Operation_Type_Incompatible
  # - Failure_Property_Modify_Unsupported_Modification_Type
  # - Failure_Property_Modification_Type_Invalid
  # - Failure_Property_Value_Invalid
