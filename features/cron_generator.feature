Feature: Cron generator

  Scenario: Using cron generator when generating a new daemon
    When I run `daemon-kit vuvuzela -i cron`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | config/pre-daemonize/cron.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain:
    """
    gem 'rufus-scheduler'
    """

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate cron` interactively
    And I accept the conflicts
    Then the following files should exist:
      | config/pre-daemonize/cron.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain:
    """
    gem 'rufus-scheduler'
    """

