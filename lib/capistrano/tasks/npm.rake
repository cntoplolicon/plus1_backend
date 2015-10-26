namespace :npm do
  task :build do
    on roles fetch(:npm_roles) do
      within fetch(:npm_target_path, release_path) do
        with fetch(:npm_env_variables, {}) do
          execute :npm, 'build', fetch(:npm_flags)
        end
      end
    end
  end

  task :deploy do
    on roles fetch(:npm_roles) do
      within fetch(:npm_target_path, release_path) do
        with fetch(:npm_env_variables, {}) do
          execute :npm, :run, :deploy, fetch(:npm_flags)
        end
      end
    end
  end

  after :install, :deploy
end
