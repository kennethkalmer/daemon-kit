# Safely is responsible for providing exception reporting and the
# logging of backtraces when your daemon dies unexpectedly. The full
# documentation for safely can be found at
# http://github.com/kennethkalmer/safely/wiki

# By default Safely will use the daemon-kit's logger to log exceptions,
# and will store backtraces in the "log" directory.

# Comment out to enable Hoptoad support
# Safely::Strategy::Hoptoad.hoptoad_key = ""

# Comment out to use email exceptions
# Safely::Strategy::Mail.recipient = "your.name@gmail.com"
