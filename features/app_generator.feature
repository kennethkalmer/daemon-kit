Feature: Generating a new daemon

  daemon-kit offers an application generator to get you started.

  Scenario: Generator offers help
    When I run `daemon-kit`
    Then the output should contain:
    """
    Usage:
      daemon-kit app APP_PATH
    """

  Scenario: Generating a default daemon
    When I run `daemon-kit vuvuzela`
    Then the following files should exist:
      | vuvuzela/README |
      | vuvuzela/Rakefile |
      | vuvuzela/bin/vuvuzela |
      | vuvuzela/config/arguments.rb |
      | vuvuzela/config/boot.rb |
      | vuvuzela/config/environments/development.rb |
      | vuvuzela/config/environments/test.rb |
      | vuvuzela/config/environments/production.rb |
      | vuvuzela/config/pre-daemonize/readme |
      | vuvuzela/config/post-daemonize/readme |
      | vuvuzela/lib/vuvuzela.rb |
      | vuvuzela/libexec/vuvuzela-daemon.rb |
      | vuvuzela/script/console |
      | vuvuzela/script/destroy |
      | vuvuzela/script/generate |
      | vuvuzela/spec/spec_helper.rb |
    And the following directories should exist:
      | vuvuzela/log |
      | vuvuzela/tasks |
      | vuvuzela/vendor |
      | vuvuzela/tmp |
