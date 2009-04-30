# Generated nanite agent daemon

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

# IMPORTANT CONFIGURATION NOTE
#
# Please review and update 'config/nanite.yml' accordingly or this
# daemon won't work as advertised.
#
# Your actors live in DAEMON_ROOT/lib/actors

# Run the agent, and get the running agent.
DaemonKit::Nanite::Agent.run do |agent|
  # Use the yielded agent instance to register your actors:
  agent.register Sample.new
  
  # This block can used to make your agent perform other tasks as
  # well. Remember that you have access to a running EventMachine
  # reactor since the AMQP gem used by nanite uses it. Other than that
  # you can mostly leave this file alone and concentrate on developing
  # your actors in the lib/actors/ directory of the project.
end
