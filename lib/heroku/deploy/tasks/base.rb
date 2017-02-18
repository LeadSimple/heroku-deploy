module Heroku::Deploy::Task
  class Base
    attr_accessor :strategy, :app, :environment

    def initialize(strategy)
      @strategy = strategy
      @app      = strategy.app
      @environment = strategy.environment
    end

    def rollback_before_deploy; end
    def before_deploy; end

    def deploy; end
    def rollback_deploy; end

    def rollback_after_deploy; end
    def after_deploy; end
  end
end
