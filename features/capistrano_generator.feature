Feature: Capistrano generator provides some additional infrastructure

  Scenario: Using the capistrano generator when generating a new daemon
    When I run `daemon-kit vuvuzela -d capistrano`
    And I cd to "vuvuzela"
    Then the following files should exist:
      | Capfile |
      | config/deploy.rb |
      | config/deploy/staging.rb |
      | config/deploy/production.rb |

  Scenario: Using AMQP generator on an existing daemon
    Given I have an existing daemon called "vuvuzela"
    And I cd to "vuvuzela"
    When I run `./script/generate capistrano`
    Then the following files should exist:
      | Capfile |
      | config/deploy.rb |
      | config/deploy/staging.rb |
      | config/deploy/production.rb |
