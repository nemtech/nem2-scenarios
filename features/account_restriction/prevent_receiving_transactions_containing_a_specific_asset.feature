Feature: Prevent receiving transactions containing a specific asset
  As Bobby,
  I only want to receive "cat.currency" assets
  So that I can ensure I don't own assets unrelated with my activity

  Background:
    # This step registers every user with cat.currency
    Given the following accounts exist:
      | Alex  |
      | Bobby |
      | Carol |
    And Alex has the following assets registered and active:
      | ticket  |
      | voucher |

  Scenario: An account blocks receiving transactions containing a specific asset
    Given Bobby blocks receiving transactions containing the following assets:
      | ticket  |
      | voucher |
    When Alex tries to send 1 asset "ticket" to Bobby
    Then Bobby should receive a confirmation message
    And Alex should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Prohibited"
    And Bobby balance should remain intact
    And Alex balance should remain intact

  Scenario Outline: An account allows receiving transactions containing a specific asset
    Given Bobby allows receiving transactions containing the following assets:
      | <asset> |
    When Alex sends <amount> asset "<asset>" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive <amount> of asset "<asset>"
    And Alex "<asset>" balance should decrease by <amount> units

    Examples:
      | amount | asset        |
      | 10     | cat.currency |
      | 10     | ticket       |

  Scenario: Assets remaining in blocked list after some are unblocked should remain blocked and not be transferable
    Given Bobby blocks receiving transactions containing the following assets:
      | ticket  |
      | voucher |
    When Bobby removes ticket from blocked assets
    And Alex tries to send 1 asset "voucher" to Bobby
    Then Alex should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Prohibited"

  Scenario: A blocked asset when unblocked should be transferable
    Given Bobby blocks receiving transactions containing the following assets:
      | ticket  |
      | voucher |
    And Bobby removes ticket from blocked assets
    When Alex tries to send 1 asset "ticket" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive 1 of asset "ticket"

  Scenario: An only allowed asset when removed from allowed assets should not be transferable
    Given Bobby has only allowed receiving the following assets
      | ticket  |
      | voucher |
    And Bobby removes ticket from allowed assets
    When Alex tries to send 1 asset "ticket" to Bobby
    Then Alex should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Prohibited"

  Scenario: Assets remaining in allowed assets after some are removed should be transferable
    Given Bobby has only allowed receiving the following assets
      | ticket  |
      | voucher |
    When Bobby removes ticket from allowed assets
    And Alex sends 1 asset "voucher" to Bobby
    Then Bobby should receive a confirmation message
    And Bobby should receive 1 of asset "voucher"

  Scenario: An account unblocks a not blocked asset
    Given Bobby has blocked receiving ticket assets
    When Bobby tries to remove voucher from blocked assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account removes an asset that does not exist in the allowed assets
    Given Bobby has blocked receiving ticket assets
    When Bobby tries to remove voucher from allowed assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account tries only to allow receiving transactions containing specific assets when it has blocked assets
    Given Bobby has blocked receiving ticket assets
    When Bobby tries to only allow receiving voucher assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account tries to block receiving transactions containing specific assets when it has allowed assets
    Given Bobby has only allowed receiving ticket assets
    When Bobby tries to block receiving voucher assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account tries to block an asset twice
    Given Bobby has blocked receiving ticket assets
    When Bobby tries to block receiving ticket assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account tries to allow an asset twice
    Given Bobby has only allowed receiving ticket assets
    When Bobby tries to only allow receiving ticket assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Invalid_Modification"

  Scenario: An account tries add too many restrictions in a single transaction
    Given Alex has 515 different assets registered and active
    When Bobby tries to add more than 512 restrictions in a transaction
    Then Bobby should receive the error "Failure_RestrictionAccount_Modification_Count_Exceeded"

  Scenario: An account tries delete too many restrictions in a single transaction
    Given Alex has 515 different assets registered and active
    When Bobby tries to delete more than 512 restrictions in a transaction
    Then Bobby should receive the error "Failure_RestrictionAccount_Modification_Count_Exceeded"

  Scenario: An account tries to block too many mosaics
    Given Bobby has already blocked receiving 512 different assets
    When Bobby tries to block receiving ticket assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Values_Count_Exceeded"

  Scenario: An account tries to only allow too many mosaics
    Given Bobby has already allowed receiving 512 different assets
    When Bobby tries to only allow receiving ticket assets
    Then Bobby should receive the error "Failure_RestrictionAccount_Values_Count_Exceeded"
