Feature: Get balance transfers
  As Alice
  I want to know why my balance was decrease
  after registering a mosaic or a namespace

  # Mosaic
  Scenario: Alice wants to get the cost of registering an asset
    Given Alice registered the asset "alice.token"
    When Alice checks how much cost registering the asset
    Then she should get that registering the asset cost "50" xem

  # Namespace
  Scenario Outline: Alice wants to get the cost of registering a namespace
    Given Alice registered a namespace named <name> for <time> seconds
    When she checks how much cost registering the namespace
    Then she should get that registering the namespace cost "<cost>" xem

    Examples:
      | name  | time | cost |
      | test1 | 15   | 0.1  |
      | test1 | 20   | 0.2  |
      | test2 | 30   | 0.2  |

  Scenario Outline: Alice wants to get the cost of extending a namespace
    Given "Alice" registered the namespace "alice" for a week
    And she extended the registration of the namespace named "alice" for <time> seconds
    When she checks how much cost extending the namespace
    Then she should get that extending the namespace cost "<cost>" xem

    Examples:
      | time | cost |
      | 15   | 0.1  |
      | 20   | 0.2  |
      | 30   | 0.2  |

  # Receipts not treated:
  # - Mosaic_Levy
