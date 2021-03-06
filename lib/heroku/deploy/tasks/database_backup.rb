module Heroku::Deploy::Task
  class DatabaseBackup < Base
    include Heroku::Deploy::Shell

    def self.backup(strategy)
      new(strategy).backup
    end

    def backup
      env_vars = app.env.dup
      env_vars['RAILS_ENV'] = 'production'

      task "Backing up the remote database" do
        shell "heroku pgbackups:capture --expire --app #{app.name}"
      end
    end
  end
end
