Feature: Apply global restrictions on mosaics
  As Alex I want to put one or more restrictions on mosaics
  Accounts that do not pass the restriction cannot transact with the mosaic
  And accounts that pass the restriction should be able to transact with the mosaic

  Background:
    # This step registers every user with cat.currency
    Given the following accounts exist:
      | Alex    |
      | Bobby   |
      | Carol   |
    And Alex has the following assets registered and active:
      | exp.currency     |
    And Bobby has at least 1 exp.currency balance

  Scenario: An account that doesn't pass the restriction cannot transact with the mosaic
    Given Alex creates a following restriction
     | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
     | exp.currency     | can_hold            |  1                    |   EQ                   |
    And Bobby has the following restriction key
     | restriction key   | restriction value       |
     | can_hold          |         0               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Bobby should receive an error "......."

  Scenario: An account that passes the restriction should be able to transact with the mosaic
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | can_hold            |  1                    |   EQ                   |
    And Bobby has the following restriction key
      | restriction key       | restriction value       |
      | can_hold              |         1               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Carol should receive 1 of asset "exp.currency"

  Scenario: An account that doesn't pass multiple restriction cannot transact with the mosaic
    Given Alex creates a following restriction
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | can_hold            |  1                    |   EQ                   |
      | exp.currency     | can_share           |  2                    |   EQ                   |
    And Alex makes a modification to the mosiac restriction
      | restriction key       | restriction value       |
      | can_hold              |         0               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Bobby should receive an error

  Scenario: An account that passes multiple restrictions can interact with the mosaic
    Given Alex creates a following restrictions
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | can_hold            |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | can_hold              |         1               |
      | can_share             |         1               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Carol should receive 1 of asset "exp.currency"

  Scenario: An account that cannot pass the right restriction cannot do the corresponding transaction with mosaic
    Given Alex creates a following restrictions
      | Mosaic           | Restriction Key     |  Restriction value    |   Restriction Type     |
      | exp.currency     | can_hold            |  1                    |   EQ                   |
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And only users with following restriction can send mosaics to other users
      | exp.currency     | can_share           |  1                    |   EQ                   |
    And Bobby has the following restriction keys
      | restriction key       | restriction value       |
      | can_hold              |         1               |
      | can_share             |         0               |
    When Bobby tries to send 1 asset "exp.currency" to Carol
    Then Bobby should receive an error
