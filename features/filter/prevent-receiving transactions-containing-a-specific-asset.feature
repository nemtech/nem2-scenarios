Feature: Prevent receiving transactions containing a specific asset
  As Alice,
  I only want to receive "xem" assets
  So that I can ensure I don't own assets unrelated with my activity

  Background:
    Given the following assets are registered and active:
    |asset  |
    |ticket |
    |voucher|
    |xem    |

  Scenario: An account blocks receiving transactions containing a specific asset
    When Alice blocks receiving transactions containing the following assets:
      | asset              |
      | ticket             |
      | voucher            |
    Then she should receive a confirmation message
    And receiving the stated assets should be blocked

  Scenario: An account allows only receiving transactions containing a specific asset
    When Alice only allows receiving transactions containing type:
      | asset              |
      | xem                |
    Then she should receive a confirmation message
    And  receiving the stated assets should be allowed

  Scenario: An account unblocks an asset
    Given Alice blocked receiving transactions containing the following assets:
      | asset              |
      | ticket             |
      | voucher            |
    When Alice unblocks "ticket"
    Then she should receive a confirmation message
    And receiving "voucher" assets should remain blocked

  Scenario: An account removes an asset from the allowed assets
    Given Alice only allowed receiving "ticket" assets
      | asset              |
      | ticket             |
      | voucher            |
    When Alice removes "ticket" from the allowed assets
    Then she should receive a confirmation message
    And only receiving "voucher" assets should remain allowed

  Scenario: An account unblocks an asset that is not blocked
    Given Alice blocked receiving "ticket" assets
    When Alice unblocks "voucher"
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST

  Scenario: An account removes an asset that does not exist in the allowed assets
    Given Alice blocked receiving "ticket" assets
    When Alice removes "voucher" from the allowed assets
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST

  Scenario: An account tries only to allow receiving transactions containing specific assets when it has blocked assets
    Given Alice blocked receiving "ticket" assets
    When Alice only allows receiving "voucher" assets
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST

  Scenario: An account tries to block receiving transactions containing specific assets when it has allowed assets
    Given Alice only allowed receiving "ticket" assets
    When Alice blocks receiving "voucher" assets
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST"

  Scenario: An account tries to block an asset twice
    Given Alice blocked receiving "ticket" assets
    When Alice blocks receiving "ticket" assets
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST

  Scenario: An account tries to allow an asset twice
    Given Alice only allowed receiving "ticket" assets
    When Alice only allows receiving "ticket" assets
    Then she should receive the error "error"
    #Todo: Define status error in Catapult REST
