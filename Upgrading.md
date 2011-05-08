Some important upgrading information
====================================

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
