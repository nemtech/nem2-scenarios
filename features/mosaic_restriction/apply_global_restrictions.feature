Feature: Apply global restrictions on a mosaic
  As Alex I want to enforce a global restriction on a mosaic
  So that accounts that do not pass the restriction cannot transact with the mosaic

  Background:
    # This step registers every user with cat.currency
    Given the following accounts exist:
      | Alex    |
      | Bobby   |
      | Carol   |
    And following mosaics are registered in the network:
      | mosaic           | restrictable     |  quantity
      | exp.currency     | true             |   100    |
      | tickets          | true             |   100    |
      | voucher          | false            |   100    |
#    And an account can only define up to 512 mosaic filters


  Scenario: 1. An account that doesn't pass the restriction cannot transact with the mosaic
    Given Alex creates a following restriction
     | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
     | exp.currency     | eligibility         |  1                    |   EQ                   |
    And Bobby has the following restriction key
     | restriction key       | restriction value       |
     | eligibility           |         0               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Bobby should receive the error " ..... "

  Scenario: 2. An account that passes the restriction should be able to transact with the mosaic
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
    And Bobby has the following restriction key
      | restriction key       | restriction value       |
      | eligibility           |         1               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Carol should receive 1 of asset "exp.currency"

  Scenario: 3. Remove global restriction on an asset
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
    And Alex makes a modification to the mosiac
      | mosaic           | restrictable     |
      | exp.currency     | false            |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Carol should receive 1 of asset "exp.currency"

  Scenario: 4. An account that does not pass multiple restrictions should not be able to transact with mosaic
    Given Alex creates a following restrictions
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | eligibility           |         1               |
      | can_share             |         0               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Bobby should receive the error " ..... "

  Scenario: 5. An account that passes multiple restrictions should be able to transact with mosaic
    Given Alex creates a following restrictions
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | eligibility           |         1               |
      | can_share             |         1               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Carol should receive 1 of asset "exp.currency"

  Scenario: 6. Remove one of two global restriction on an asset and an eligible account should be able to interact
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | eligibility           |         1               |
      | can_share             |         0               |
    When Alex removes the following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    Then Bobby tries to send 1 asset "exp.currency" to Carol
    And Carol should receive 1 of asset "exp.currency"

  Scenario: 6. Remove both global restrictions on an asset and an account should be able to interact
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | eligibility         |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | eligibility           |         0               |
      | can_share             |         0               |
    When Alex makes a modification to the mosiac
      | mosaic           | restrictable     |
      | exp.currency     | false            |
    Then Bobby tries to send 1 asset "exp.currency" to Carol
    And Carol should receive 1 of asset "exp.currency"

#    **************** Address restrictions **************
#    This scenario is not clear
  Scenario: 7. Verify integrity when one of multiple restrictions is removed
    As Alex when I enforce multiple global restrictions on an asset
    And Bobby does not pass both the restrictions
    And Alex removes one global restriction
    Then Bobby should be able to transact only without first restriction

  Scenario: 8. Verify multiple accounts that pass the restrictions are able to interact
    As Alex I enforce a restriction on a mosaic
    And Bobby and Carol pass the restriction
    Then Bobby and Carol should be able to transact with the mosaic

  Scenario: 9. Verify that multiple accounts that do not pass the restrictions are not able to interact among themselves
  As Alex I enforce a restriction on a mosaic
   And Bobby passes the restriction
   And Carol does not pass the restriction
   Then Bobby should not be able to transact with Carol with the mosaic

#    One scenario for each restriction type? (There are 7 restriction types)
