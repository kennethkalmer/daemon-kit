#set :deploy_to, "/svc/<%= name %>" # defaults to "/u/apps/#{application}"
#set :user, "<% name %>"            # defaults to the currently logged in user
set :daemon_env, 'staging'

set :domain, 'example.com'
server domain
