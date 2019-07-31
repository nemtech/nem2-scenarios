@not-implemented
Feature: Exchange assets across different blockchains
  As Alice,
  I want to exchange assets with Bob across different blockchains,
  so that there is no need to trust in each other.

  Background:
    Given assets can be locked up to 30 days
    And the mean block generation time is 15 seconds
    And the secret seed length should be between 10 and 1000 bytes
    And the maximum secret lock duration is 30 days
    And the following hashing algorithms are available:
      | hash_type |
      | SHA_512   |
      | Keccak    |
      | Hash_160  |
      | Hash_256  |
    And "Alice" owns 999999 "alice:token" units in "MIJIN"
    And "Alice" owns an account in "MAIN_NET"
    And "Bob" owns 999999 bob:token units in "MAIN_NET"
    And "Bob" owns an account in "MIJIN"

  Scenario Outline: An account derives the secret from the secret's seed
    Given Alice generated the random seed "<seed>"
    When she derived secret from the seed with "<hash_type>"
    Then the secret should be "<secret>"
    Examples:
      | seed                 | hash_type | secret                                                                                                                           |
      | 51961300df0d60e69b0d | SHA_512   | 8AF159EB455640D7295ACC2D719E3F3ABCB8D00E737CA1490EBD99586456F65B4B7008A524F6ECD127B9B38D10B03DDEC969D6BF81ED39D19CC767CBF374EE39 |
  # Todo: Add more algorithms in the future

  Scenario: An account locks assets
    Given Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | days |
      | 10     | alice.token | Bob       | MIJIN   | 96   |
    Then she should receive a confirmation message
    And her "alice.token" balance should have decreased in 10 units

  Scenario Outline: An exchange of assets across different blockchains concludes
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | days |
      | 10     | alice.token | Bob       | MIJIN   | 96   |
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | days |
      | 10     | bob.token | Alice     | MAIN_NET | 84   |
    When "Alice" proves knowing the secret's seed in "MAIN_NET"
    And "<signer>" proves knowing the secret's seed in "MIJIN"
    Then "Alice" should receive 10 "bob.token" in "MAIN_NET"
    And "Bob" should receive 10 "alice.token" in "MIJIN"

    Examples:
      | signer |
      | Alice  |
      | Bob    |
      | Carol  |

  Scenario: An exchange of assets doesn't conclude because the second participant decides not locking the assets
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    When "Bob" decides not locking the assets
    Then "Alice" should receive 10 "alice.token" in "MIJIN" after 96 hours

  Scenario: An exchange of assets doesn't conclude because the first participant decides not to prove to know the secret's seed
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | hours |
      | 10     | bob.token | Alice     | MAIN_NET | 84    |
    When "Alice" decides not to prove to know the secret's seed
    Then "Alice" should receive 10 "alice.token" in "MIJIN" after 96 hours
    And "Bob" should receive 10 "bob.token" in "MAIN_NET" after 84 hours

  Scenario: An exchange of assets doesn't conclude because the second participant didn't prove the secret's seed
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | hours |
      | 10     | bob.token | Alice     | MAIN_NET | 84    |
    And Alice proved knowing the secret's seed in "MAIN_NET" receiving 10 bob.token
    When "Bob" decides not to prove to know the secret's seed
    Then "Alice" should receive 10 "alice.token" in "MIJIN" after 84 hours

  Scenario: An exchange of assets doesn't conclude because there is not enough time
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 10    |
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | hours |
      | 10     | bob.token | Alice     | MAIN_NET | 20    |
    And "Alice" proved knowing the secret's seed in "MAIN_NET" after 12 hours
    When "Bob" proves knowing the secret's seed in "MAIN_NET" after 12 hours
    Then "Bob" should receive the error "Failure_LockSecret_Inactive_Secret"

  Scenario: An account tries to lock assets using an unimplemented algorithm
    Given Alice derived the secret from the seed using "MD5"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 10    |
    Then she should receive the error "Failure_LockSecret_Hash_Not_Implemented"

  Scenario: An account tries to lock assets that does not have
    Given Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset     | recipient | network | hours |
      | 10     | bob.token | Bob       | MIJIN   | 10    |
    Then she should receive the error "Failure_Core_Insufficient_Balance"

  Scenario Outline: An account tries to lock assets but the duration set is invalid
    Given Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | days   |
      | 10     | alice.token | Bob       | MIJIN   | <days> |
    Then she should receive the error "Failure_LockSecret_Invalid_Duration"

    Examples:
      | days |
      | -1   |
      | 31   |

  Scenario: An account tries to lock assets using a used secret
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 2     |
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 2     |
    Then she should receive the error "Failure_LockSecret_Hash_Exists"

  Scenario Outline: An account tries to lock assets but the recipient address used is not valid
    Given Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network  | hours |
      | 10     | alice.token | <address> | MAIN_NET | 96    |
    Then she should receive the error "<error>"

    Examples:
      | address                                        | error                        |
      | SAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H  | Failure_Core_Invalid_Address |
      | LAIBV5-BKEVGJ-IZQ4RP-224TYE-J3ZIUL-WDHUTI-X3H5 | Failure_Core_Wrong_Network   |

  Scenario: An account tries to lock assets but the recipient does not allow this asset
    Given Bob only allowed receiving "cat.currency" assets
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Not_Allowed"

  Scenario: An account tries to lock assets but the recipient has blocked this asset
    Given Bob blocked receiving "alice.token" assets
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Mosaic_Transfer_Not_Allowed"

  Scenario: An account tries to lock assets but the recipient account does not allow receiving transactions from it
    Given Bob only allowed receiving transactions from Carol
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Address_Interaction_Not_Allowed"

  Scenario: An account tries to lock assets but the recipient has blocked it
    Given Bob blocked receiving transactions from Alice
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Address_Interaction_Not_Allowed"

  Scenario: An account tries to lock assets but has not allowed sending "LOCK_SECRET" transactions
    Given Alice only allowed sending "TRANSFER" transactions
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"

  Scenario: An account tries to lock assets but has blocked sending "LOCK_SECRET" transactions
    Given Alice blocked sending "LOCK_SECRET" transactions
    And Alice derived the secret from the seed using "SHA_512"
    When "Alice" locks the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"

  Scenario: An account tries to prove knowing a secret's seed that has not been used
    Given Alice derived the secret from the seed using "SHA_512"
    When Alice proves knowing the secret's seed in "MIJIN"
    Then she should receive the error "Failure_LockSecret_Unknown_Secret"

  Scenario: An account tries to unlock assets but the secret doesn't equal the hashed seed
    Given Alice derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 2     |
    When Alice proves knowing the secret's seed in "MIJIN" but was copied partially
    Then she should receive the error "Failure_LockSecret_Secret_Mismatch"

  Scenario Outline: An account tries to unlock assets but the seed used was too large
    Given Alice generated a <length> character length seed
    And  "Alice" derived the secret from the seed using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 2     |
    When Alice proves knowing seed in "MIJIN"
    Then she should receive the error "Failure_LockSecret_Proof_Size_Out_Of_Bounds"

    Examples:
      | length |
      | 9      |
      | 1001   |

  Scenario: An account tries to unlock assets using a different algorithm
    Given "Alice" derived the secret using "SHA_512"
    And "Alice" locked the following asset units using the previous secret:
      | amount | asset       | recipient | network | hours |
      | 10     | alice.token | Bob       | MIJIN   | 96    |
    When Alice proves knowing the secret's seed in "MIJIN" selecting "Keccak" as the hashing algorithm
    Then she should receive the error "Failure_LockSecret_Hash_Algorithm_Mismatch"

  # Account Restrictions
  Scenario: An account tries to unlock assets but has not allowed sending "SECRET_PROOF" transactions
    Given Alice only allowed sending "SECRET_PROOF" transactions
    And Bob derived the secret from the seed using "SHA_512"
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | hours |
      | 10     | bob.token | Alice     | MAIN_NET | 84    |
    When "Alice" proved knowing the secret's seed in "MAIN_NET"
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"

  Scenario: An account tries to unlock assets but has blocked sending "SECRET_PROOF" transactions
    Given Alice blocked sending "SECRET_PROOF" transactions
    And Bob derived the secret from the seed using "SHA_512"
    And "Bob" locked the following asset units using the previous secret:
      | amount | asset     | recipient | network  | hours |
      | 10     | bob.token | Alice     | MAIN_NET | 84    |
    When "Alice" proved knowing the secret's seed in "MAIN_NET"
    Then she should receive the error "Failure_RestrictionAccount_Transaction_Type_Not_Allowed"
