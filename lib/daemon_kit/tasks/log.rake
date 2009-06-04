namespace :log do
  desc "Truncate all log files found in DAEMON_ROOT/log/"
  task :truncate => 'environment' do
    Dir[ "#{DaemonKit.root}/log/*.log" ].each do |l|
      File.open( l, 'w+' ) { |f| f.write('') }
    end
  end
end
