Feature: Create a mosaic
  As Alice
  I want to create a mosaic
  So that I can share them with Bob and Carol.

  Background:
    Given creating a mosaic costs 50 xem per block
    And creating a non-expiring mosaic costs 5000 xem
    And the maximum mosaic duration is one year
    And the mean block generation time is 15 seconds
    And the maximum mosaic divisibility is 6
    And the maximum mosaic supply is 9000000000
    And Alice has 100000 xem in her account

  Scenario Outline: An account creates an expiring mosaic
    When Alice creates a mosaic for <blocks> blocks
    Then she should become the owner of the new mosaic
    And it should be registered for <blocks> blocks
    And her xem balance should decrease in <cost> units

    Examples:
      |blocks| cost |
      | 1    | 50   |
      | 2    | 100  |

  Scenario Outline: An account creates a non-expiring mosaic
    When Alice creates a mosaic non-expiring mosaic
    Then she should become the owner of the new mosaic
    And it should be non-expiring
    And her xem balance should decrease in <cost> xem

    Examples:
      | cost |
      | 5000 |

  Scenario Outline: An account creates a mosaic with invalid duration
    When Alice creates a mosaic for <blocks> blocks
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | blocks   | error                           |
      | -1       | Failure_Mosaic_Invalid_Duration |
      | 63070000 | Failure_Mosaic_Invalid_Duration |

  Scenario Outline: An account creates a new mosaic with a valid initial supply
    When Alice creates a mosaic with an initial supply of <supply> for 1 block
    Then she should become the owner of the new mosaic
    And it should have a supply of <supply>

    Examples:
      |supply      |
      | 1          |
      | 9000000000 |

  Scenario Outline: An account creates a new mosaic with an invalid initial supply
    When Alice creates a mosaic with an initial supply of <supply> for 1 block
    Then she should receive the error <error>
    And her xem balance should remain intact

    Examples:
      | supply     | error                                       |
      | -1         | Failure_Mosaic_Supply_Negative              |
      | 0          | Failure_Mosaic_Invalid_Supply_Change_Amount |
      | 9000000001 | Failure_Mosaic_Supply_Exceeded              |

  Scenario Outline: An account creates a mosaic with a valid property
    When Alice creates a <property> mosaic for 1 block
    Then she should become the owner of the new mosaic
    And it should have the property <property>

    Examples:
      | property         |
      | transferable     |
      | non-transferable |
      | supply mutable   |
      | supply immutable |
      | levy mutable     |
      | levy immutable   |

  Scenario Outline: An account creates an mosaic with an invented property
    When Alice creates a non-fungible mosaic for 1 block
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | error |
      | Failure_Mosaic_Invalid_Property |

  Scenario Outline: An account creates a mosaic with a valid divisibility
    When Alice creates a mosaic with divisibility <divisibility> for 1 block
    Then she should become the owner of the new mosaic
    And the mosaic should handle up to <divisibility> decimals

    Examples:
      | divisibility |
      | 0            |
      | 6            |

  Scenario Outline: An account creates a mosaic with an invalid divisibility
    When Alice creates a mosaic with divisibility <number> for 1 block
    Then she should receive the error "<error>"
    And her xem balance should remain intact

    Examples:
      | number | error                           |
      | -1     | Failure_Mosaic_Invalid_Property |
      | 7      | Failure_Mosaic_Invalid_Property |

  Scenario Outline: An account does not have enough funds
    Given Alice has spent all her xem
    When Alice creates a mosaic for <blocks> blocks
    Then she should receive the error "<error>"

  Examples:
    |blocks | error                             |
    | 1     | Failure_Core_Insufficient_Balance |