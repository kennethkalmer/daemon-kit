# Generated jabber daemon

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
# Please review and update 'config/jabber.yml' accordingly or this
# daemon won't work as advertised.

# This block gets called every time a message has been received from a
# valid master.
DaemonKit::Jabber.received_messages do |message|
  # Simple echo service
  DaemonKit::Jabber.deliver( message.from, message.body )
end

# Run our Jabber bot
DaemonKit::Jabber.run
