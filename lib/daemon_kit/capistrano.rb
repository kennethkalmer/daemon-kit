namespace :load do
  task :defaults do
    set :daemon_default_hooks, -> { true }
    set :daemon_cmd, -> { "./bin/#{fetch(:application)}" }
    set :daemon_pid, -> { File.join(shared_path, 'log', "#{fetch(:application)}.pid") }
    set :daemon_env, "production"
    set :daemon_role, :app

    # Rbenv and RVM integration
    # set :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(%w{ puma pumactl })
    # set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w{ puma pumactl })

    # Our logs
    set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp')
  end
end

namespace :deploy do
  before :starting, :check_daemon_hooks do
    invoke 'daemon:add_default_hooks' if fetch(:daemon_default_hooks)
  end
end

namespace :daemon do

  desc 'Start daemon'
  task :start do
    on roles (fetch(:daemon_role)) do
      within current_path do
        with daemon_env: fetch(:daemon_env) do

          execute :bundle, 'exec', fetch(:daemon_cmd), "start --pid #{fetch(:daemon_pid)}"
        end
      end
    end
  end

  %w[halt stop status].map do |command|
    desc "#{command} daemon"
    task command do
      on roles (fetch(:daemon_role)) do
        within current_path do
          with daemon_env: fetch(:daemon_env) do
            if test "[ -f #{fetch(:daemon_pid)} ]"
              if test "kill -0 $( cat #{fetch(:daemon_pid)} )"
                execute :bundle, 'exec', fetch(:daemon_cmd), "#{command} --pid #{fetch(:daemon_pid)}"
              else
                # delete invalid pid file , process is not running.
                execute :rm, fetch(:daemon_pid)
              end
            else
              #pid file not found, so puma is probably not running or it using another pidfile
              warn 'Daemon not running'
            end
          end
        end
      end
    end
  end

  %w[restart].map do |command|
    desc "#{command} daemon"
    task command do
      on roles (fetch(:daemon_role)) do
        within current_path do
          with daemon_env: fetch(:daemon_env) do
            if test "[ -f #{fetch(:daemon_pid)} ]" and test "kill -0 $( cat #{fetch(:daemon_pid)} )"
              # NOTE pid exist but state file is nonsense, so ignore that case
              execute :bundle, 'exec', fetch(:daemon_cmd), "stop --pid #{fetch(:daemon_pid)}"
            else
              # Puma is not running or state file is not present : Run it
              invoke 'daemon:start'
            end
          end
        end
      end
    end
  end

  task :add_default_hooks do
    #after 'deploy:check', 'puma:check'
    after 'deploy:finished', 'daemon:restart'
  end

end
