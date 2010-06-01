# Generated remote participant for the ruote workflow engine
# (http://openwferu.rubyforge.org)

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
# Please review and update 'config/amqp.yml' accordingly if you wish to use
# AMQP as a transport mechanism for workitems sent between ruote and this
# daemon.

# Configuration of the remote participant shell
DaemonKit::RuoteParticipants.configure do |config|
  # Use AMQP as a workitem transport mechanism
  config.use :amqp

  # Register your classes as pseudo-participants, with work being delegated
  # according to the 'command' parameter passed in the process definition
  config.register Sample
end

DaemonKit::RuoteParticipants.run do
  # Place any additional daemon-specific code in here...
end
