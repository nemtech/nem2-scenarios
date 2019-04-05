Feature: Get artifact expiration
  As Alice
  I want to know when a namespace or asset expired

  # Mosaic
  Scenario: An account wants to know when the asset expired
    Given an asset that Alice has registered has expired
    When Alice checks when the asset expired
    Then she should get an estimated time reference

  # Namespace
  Scenario: An account tries to get if a namespace expired
    Given Alice registers a namespace named  "alice.token" for 15 seconds
    And the namespace expires
    When Alice checks if the previous namespace expired
    Then she should get an estimated time reference
