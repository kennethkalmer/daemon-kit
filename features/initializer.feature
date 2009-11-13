DaemonKit initializer operates on a timeline
DaemonKit needs to fire events as the timeline proceeds
DaemonKit needs a default stack

Scenario: By default, the timeline should several events
Given the initializer is loaded
Then the timeline should not be empty
And the timeline should start with the "framework" event
Then the timeline should follow with the "argument" event
Then the timeline should follow with the "environment" event
Then the timeline should follow with the "dependencies" event
Then the timeline should follow with the "before_daemonize" event
Then the timeline should follow with the "after_daemonize" event
Then the timeline should follow with the "application" event
Then the timeline should follow with the "shutdown" event
