# Changelog

DaemonKit endures to use semantic versioning, at least since the 0.3.0 release.
Below is a curated list of important changes/fixes/improvements. You can use
GitHub's excellent compare view to get the nitty gritty details.

## 0.4.0 Unreleased

* No longer close IO we don't own when daemonizing. [#85](https://github.com/kennethkalmer/daemon-kit/issues/85)

## 0.3.1 2014-07-21

* Removed the dependency on the i18n gem
* Locked rufus-scheduler dependency to 2.0.x #79
* Pass YAML files through ERB #80
* Ensure proper shutdown of AMQP connections #84

## 0.3.0 2014-05-15

* No changes, released final version

## 0.3.0.rc2 2013-09-23

* [safely](https://github.com/kennethkalmer/safely) usage is now optional, although included by default. #73
* XMPP abstractions fixed and now requires Blather ~> 0.8.0
* Removed support for "freezing" daemon-kit into vendor/daemon-kit
* Added new "--edge" generator, creating a Gemfile that depends on daemon-kit's Github repo

## 0.3.0.rc1 2013-09-11

* Removed nanite support, nanite hasn't released in years.
* Switched generators from Rubigen to Thor
* Added Travis builds
* Added Relish documentation for us
* Switched example specs to use "pending" instead of "violated"
* Running `daemon-kit` without arguments now shows help

## 0.2.0 2012-09-30

* Depend on the 'safely' gem for the safely method and logging backtraces
* Fixed compatibility with ruote-amqp 2.2.0
* AMQP fixes by @marcbowes (version, reconnect)
* Updated to rspec 2 (various contributors)
* Various documentation fixes by @ktrix
* Remove vendored Thor
* Various load/require fixes by @ktrix
* SQS generator by @marcbowes

## 0.1.8.2 2011-05-18

* Convert to use Bundler

## 0.1.18.1 2010-08-04

* Fixed issue with our own amqp.rb file causing havoc on Ruby 1.8.7

## 0.1.18 2010-08-03

* Generators rewritten to use Thor
* Evented XMPP now handled by blather
* Boot script fixes
* Removed Jabber generator, deprecating Jabber class (use XMPP)
* Upgraded Hoptoad notifications to V2 of the notifier API
* Fix various argument handling bugs
* Removed support for exception emails
* Improved log rotation support [mperham]
* Initial 1.9.2 support
* Exception handling for scheduled tasks (cron)
* Updates for ruote-amqp versions 2.1 and later

## 0.1.7.12 2009-12-04

* Bug fix, don't load environment files twice [grockit]

## 0.1.7.11 2009-11-30

* Renamed 'daemon_kit' executable to 'daemon-kit'
* Fixed some broken links in README.rdoc
* Sneaked in << on AbstractLogger for better Logger compatibility
* Support for Test::Unit in generated projects [skaar]
* Fixed missing DAEMON_ENV for test helpers
* Fixes for nanite configuration [skaar]
* Toughened up the ruote workitem parser
* Fixed issue with nanite services not being advertised correctly [Wijnand]
* Fixed some woes with rake if rspec gem is missing

## 0.1.7.10 2009-08-12

* Ruote remote participants
* Allow process umask to be configured, defaults to 022
* Updates to DaemonKit::Config hashes
* Fixed argument parsing bug (reported by Mathijs Kwik (bluescreen303)
* Support for privilege separation (See Configuration.txt)

## 0.1.7.9 2009-06-22

* Backtraces only logged on unclean shutdown
* AMQP generator got new keep alive code

## 0.1.7.8 2009-06-22

* Optional logging of all exceptions when the daemon process dies
  unexpectedly
* Update generated environment.rb to reflect new backtraces option

## 0.1.7.7 2009-06-22

* Fixed compatibility with rufus-scheduler-2.0.0 (or newer) in cron
  generator
* Started central eventmachine reactor management code
* Now depends on eventmachine

## 0.1.7.6 (Not released)

* Support for cucumber
* Fixed issue in daemon_kit:upgrade task
* Moved rspec generator into new home
* Removed conflicting rubigen generator, messed with our script directory
* Fixed bug where environment.rb overwrites some --config values (reported by Josh Owens)

## 0.1.7.5 2009-06-08

* New AbstractLogger
  * Default Logger backend
  * SysLogLogger support
* More documentation

## 0.1.7.4 2009-06-05

* Fixed bug with control script generator (thanks Sho Fukamachi)
* Enhanced deploy.rb template to check for current dk gem verion,
  unless vendored
* Fix bug in capistrano recipe for restarting daemons
* Added log:truncate rake task
* Error mails now handled by TMail

## 0.1.7.3 2009-05-31

* Removed dependency on daemons gem, now handled in house
* New argument management
* Some more docs

## 0.1.7.1 2009-05-28

* Fixed some minor issue with Capistrano support
* Added support for generating dog/monit configuration files via rake
* Initial implementation of ./script/* utilities

## 0.1.7 2009-05-26

* Capistrano deployment support

## 0.1.6 2009-05-13

* DaemonKit::Safety class to handle the trapping and logging of
  exceptions, as well as email notifications or Hoptoad notifications.
* New config/pre-daemonize and config/post-daemonize structure
* New tasks to simplify upgrading daemon-kit projects
* Fixed some other annoyances and bugs
* Bigger TODO list

## 0.1.5 2009-05-07

* DaemonKit::Config class to easy the use of YAML configs internally,
  and in generated daemons

## 0.1.2 2009-04-28

* Added missing rubigen dependency

## 0.1.1 2009-04-27

* AMQP consumer generator added
* 'cron' style generator added
* Allow configuring dir_mode and dir (pid file location) (Jim Lindley)

## 0.1.0 2009-01-08

* Ability to freeze the gem/edge copies of DaemonKit
* Simple non-evented Jabber generator
* Flexible UNIX signal trapping configuration
* Basic generator completed
* 1 small step for man, 1 giant leap for mankind
