# Argument handling for your daemon is configured here.
#
# You have access to two variables when this file is
# parsed. The first is +opts+, which is the object yielded from
# +OptionParser.new+, the second is +@options+ which is a standard
# Ruby hash that is later accessible through
# DaemonKit.arguments.options and can be used in your daemon process.

# Here is an example:
# opts.on('-f', '--foo FOO', 'Set foo') do |foo|
#  @options[:foo] = foo
# end
