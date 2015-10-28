namespace :db do
  task :migrate do
    on fetch(:bundle_servers) do
      within release_path do
        with fetch(:bundle_env_variables, {}) do
          execute :bundle, "exec rake db:migrate RACK_ENV=#{fetch(:stage)}"
        end
      end
    end
  end

  before 'deploy:updated', 'db:migrate'
end
