Feature: SQS generator

  Scenario: Using SQS generator when generating a new daemon
    When I run `daemon-kit vuvuzela -i sqs`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | config/sqs.yml |
      | config/pre-daemonize/sqs.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain "gem 'aws-sdk'"

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate sqs` interactively
    And I accept the conflicts
    Then the following files should exist:
      | config/sqs.yml |
      | config/pre-daemonize/sqs.rb |
      | libexec/vuvuzela-daemon.rb |
    And the file "Gemfile" should contain "gem 'aws-sdk'"
