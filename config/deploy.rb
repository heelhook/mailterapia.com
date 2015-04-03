# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'mailterapia.com'
set :repo_url, 'git@github.com:heelhook/mailterapia.com.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/consulta-mailterapia/app'

set :assets_roles, [:web, :app]

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :linked_files, %w{config/database.yml config/sync.yml}

namespace :sync do
  desc 'Copy sync.yml file'
  task :setup do
    content = File.read(Pathname.new('config/sync.yml'))

    on release_roles :all do
      execute :mkdir, "-pv", File.dirname(shared_path.join('config/sync.yml'))
      upload! StringIO.new(content), shared_path.join('config/sync.yml')
    end
  end
end

task :setup do
  invoke "sync:setup"
end

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :deploy do
  namespace :assets do

    Rake::Task['deploy:assets:precompile'].clear_actions

    desc 'Precompile assets locally and upload to servers'
    task :precompile do
      on roles(fetch(:assets_roles)) do
        run_locally do
          with rails_env: fetch(:rails_env) do
            execute 'bin/rake assets:precompile'
          end
        end

        within release_path do
          with rails_env: fetch(:rails_env) do
            upload!('./public/assets/', "#{shared_path}/public/", recursive: true)
          end
        end

        run_locally { execute 'rm -rf public/assets' }
      end
    end
  end
end
