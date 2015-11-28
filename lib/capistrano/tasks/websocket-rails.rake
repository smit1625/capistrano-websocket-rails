namespace :load do
  set :websocket_rails_pid, -> { shared_path.join 'tmp', 'pids', 'websocket_rails.pid' }
  set :websocket_rails_env, -> { fetch :rack_env, fetch(:rails_env, fetch(:stage)) }
  set :websocket_rails_role, -> { :app }
end

namespace :deploy do
  before :starting, :stop_websocket_server do
    invoke 'websocket_rails:stop_server'
  end
  after :publishing, :start_websocket_server do
    invoke 'websocket_rails:start_server'
  end
end

namespace :websocket_rails do

  desc 'Start websocket-rails server'
  task :start_server do
    on roles(fetch(:websocket_rails_role)), in: :sequence, wait: 5 do
      within(release_path) { start_server }
    end
  end

  desc 'Stop websocket-rails server'
  task :stop_server do
    on roles(fetch(:websocket_rails_role)), in: :sequence, wait: 5 do
      within(current_path) { stop_server }
    end
  end

  def start_server
    info 'Starting websocket-rails server...'
    with rails_env: fetch(:websocket_rails_env) do
      rake 'websocket_rails:start_server'
    end
    info 'Websocket-rails server started.'
  end
  def stop_server
    if pid_file_exists?
      info 'Stopping websocket-rails server...'
      with rails_env: fetch(:websocket_rails_env) do
        rake 'websocket_rails:stop_server'
      end
      info 'Websocket-rails server stopped.'
    else
      info 'Websocket-rails server not running.'
    end
  end
  def pid_file_exists?
    test "[ -f #{fetch(:websocket_rails_pid)} ]"
  end

end