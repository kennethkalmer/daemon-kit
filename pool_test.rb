#!/usr/bin/env ruby

# Simple example script of using and debugging the fork pool

require "./lib/daemon_kit"
require "timeout"

Timeout.timeout( 30 ) do

  start = Time.now

  DaemonKit::ForkPool.process { p [:p1, Process.pid]; sleep 3; p [ :p1, Time.now ] }
#  sleep 0.5
  DaemonKit::ForkPool.process { p [:p2, Process.pid]; sleep 3; p [ :p2, Time.now ] }
#  sleep 0.5
  DaemonKit::ForkPool.process { p [:p3, Process.pid]; sleep 3; p [ :p3, Time.now ] }
#  sleep 0.5
  DaemonKit::ForkPool.process { p [:p4, Process.pid]; sleep 3; p [ :p4, Time.now ] }
#  sleep 0.5
  DaemonKit::ForkPool.process { p [:p5, Process.pid]; sleep 3; p [ :p5, Time.now ] }
#  sleep 0.5
  DaemonKit::ForkPool.process { p [:p6, Process.pid]; sleep 3; p [ :p6, Time.now ] }

  DaemonKit::ForkPool.wait

  puts "Completed in #{Time.now - start} seconds"

end
