Feature: Test/Unit generator

  Scenario: Using test/unit generator when generating a new daemon
    When I run `daemon-kit vuvuzela -t test_unit`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | test/test_helper.rb |
      | test/vuvuzela_test.rb |
      | tasks/test_unit.rake |

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate test_unit`
    Then the following files should exist:
      | test/test_helper.rb |
      | test/vuvuzela_test.rb |
      | tasks/test_unit.rake |
