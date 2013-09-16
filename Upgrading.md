Some important upgrading information
====================================

Upgrading to 0.3.0
------------------

From 0.2 there hasn't been any signifant changes. 0.3.0.rc2 made some changes
to the way a daemon boots, so after updating you'll need to run:

    $ rake daemon_kit:upgrade

We recommend running this task on a clean repo, or branch, so you can review
the changes using your favourite diff tool.

Upgrading to 0.1.9
------------------

The "safely" method and logging of backtraces functionality of
daemon-kit has now been extracted into a separate gem called 'safely',
which is available on github at https://github.com/kennethkalmer/safely.

You now need to add 'safely' to your Gemfile like so:

    gem "safely"

And update your _environment.rb_ to no longer configure the _safety_net_
attribute (which has been removed completely and will result in an
undefined method exception).

To configure safely, make an initializer with your configuration.
Alternatively you generate a new daemon and copy the safely initializer
into your current project as a reference.
