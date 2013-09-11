Feature: Ruote remote participant generator

  Scenario: Using ruote generator when generating a new daemon
    When I run `daemon-kit vuvuzela -i ruote`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | config/amqp.yml |
      | config/pre-daemonize/ruote.rb |
      | lib/vuvuzela.rb |
      | lib/sample.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain "gem 'amqp'"
    And the file "Gemfile" should contain "gem 'json'"

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate ruote` interactively
    And I accept the conflicts
    Then the following files should exist:
      | config/amqp.yml |
      | config/pre-daemonize/ruote.rb |
      | lib/vuvuzela.rb |
      | lib/sample.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain "gem 'amqp'"
    And the file "Gemfile" should contain "gem 'json'"
