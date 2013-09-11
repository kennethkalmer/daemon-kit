Feature: AMQP generator provides some additional infrastructure

  Scenario: Using AMQP generator when generating a new daemon
    When I run `daemon-kit vuvuzela -i amqp`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | config/amqp.yml |
      | config/pre-daemonize/amqp.rb |
      | libexec/vuvuzela-daemon.rb |

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate amqp` interactively
    And I accept the conflicts
    Then the following files should exist:
      | config/amqp.yml |
      | config/pre-daemonize/amqp.rb |
      | libexec/vuvuzela-daemon.rb |
