Feature: Generating a new daemon

  daemon-kit offers an application generator to get you started.

  Scenario: Generator offers help when no arguments are provided
    When I run `daemon-kit`
    Then the output should contain:
    """
    Usage:
      daemon-kit app APP_PATH
      """

  Scenario: Generator offers help when asked
    When I run `daemon-kit --help`
    Then the output should contain:
    """
    Usage:
      daemon-kit app APP_PATH
    """

  Scenario: Generating a default daemon
    When I run `daemon-kit vuvuzela`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | Gemfile |
      | README |
      | Rakefile |
      | bin/vuvuzela |
      | config/arguments.rb |
      | config/boot.rb |
      | config/environments/development.rb |
      | config/environments/test.rb |
      | config/environments/production.rb |
      | config/pre-daemonize/readme |
      | config/post-daemonize/readme |
      | lib/vuvuzela.rb |
      | libexec/vuvuzela-daemon.rb |
      | script/console |
      | script/destroy |
      | script/generate |
      | spec/spec_helper.rb |
    And the following directories should exist:
      | log |
      | tasks |
      | vendor |
      | tmp |
