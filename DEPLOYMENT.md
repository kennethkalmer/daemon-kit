# Deploying your daemons

daemon-kit provides built-in support for
[Capistrano 3.1+](http://capistranorb.com) deployments. In the past daemon-kit used a modified version of the Rails deployment strategies. Capistrano 3 is much more flexible and allows for a more standard experience.

## Getting started

Add the following to your `Gemfile`

```ruby
gem 'capistrano', '~> 3.3.3', require: false
gem 'capistrano-bundler', '~> 1.1.2', require: false
```

_It is important to have the `require: false` clauses or your daemon will fail to start._

Next up:

```
$ bundle install
$ cap install
```

daemon-kit no longer provides a generator for the capistrano configuration, instead we rely on something very standard :)

Next up, you need to edit the `Capfile` and add the following statements to the file:

```ruby
require "capistrano/bundler"
require "daemon_kit/capistrano"
```

## Configuring capistrano

### Bare minimum

Set the follow two values to get going quickly:

* `application` - name of your application stub in `./bin/`.
* `deploy_to` - root directory for the deployments.

### daemon-kit configs

Daemon specific deployment configuration is minimal, and optional:

* `daemon_cmd` - defaults to `./bin/:application` where _:application_ is set in the deploy.rb file.
* `daemon_pid` - defaults to `./log/:application.pid` where _:application_ is set in the deploy.rb
* `daemon_env` - defaults to `production`
* `daemon_role` - defaults to `:app` - which Capistrano role the daemon gets deployed to.

Our capistrano code adds the `log` and `tmp` directories to the `:linked_dirs` config of capistrano, ensuring common directories exist during deployment.

## Configuring your daemon

So we want to keep our private configs out of our repositories, but still have the files ready on production so our daemons are configured correctly. The easiest way to achieve this is to have Capistrano symlink those files into the deployed code from the shared directories.

Given our daemon is deployed to `/opt/daemon` by setting the `:deploy_to` value in deploy.rb, we'll get a directory layout that looks roughly like this:

```
/opt/daemon
  + current/
  	 + config/
  	   - <- SYMLINK TO HERE 
  + shared/
    + config/
      - <- SYMLINK FROM HERE 
```

By keeping copies of your production configs in capistrano's `:shared_path`, you can add those files to capistrano's `:linked_files` list for symlinking into the project.

For example

```ruby
set :linked_files, fetch(:linked_files, []).push('config/database.yml')
```

Will result in something like this:

    /opt/daemon/shared/config/database.yml -> /opt/daemon/current/config/database.yml
    
### ENV as an alternative

Most of the YAML files used by daemon-kit gets processed with ERB first, so you could also leverage this to render environment variables into the config files for production, and fallback to sensible defaults for development.

## Pulling the trigger

Once your daemon has been configured you can perform deployments by running capistrano like so:

    $ bundle exec cap staging deploy
    
This will perform the deployment for you and should get you going quickly.


## More capistrano resources

To see a list of available commands, please run the following command
in the root of your project:

    $ cap -vT

For more information on capistrano, please refer to the following list
of online resources:

* [Capistrano Website](http://www.capistranorb.com)
* [Capistrano Group](http://groups.google.com/group/capistrano)
* #capistrano on Freenode
