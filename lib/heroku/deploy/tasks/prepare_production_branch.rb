module Heroku::Deploy::Task
  class PrepareProductionBranch < Base
    include Heroku::Deploy::Shell

    def before_deploy
      @previous_branch = git "rev-parse --abbrev-ref HEAD"

      # If HEAD is returned, it means we're on a random commit, instead
      # of a branch.
      if @previous_branch == "HEAD"
        @previous_branch = git "rev-parse --verify HEAD"
      end

      # Always fetch first. The repo may have already been created.
      task "Fetching from #{colorize "origin", :cyan}" do
        git "fetch origin"
      end

      task "Switching to #{colorize strategy.branch, :cyan}" do
        branches = git "branch"

        if branches.match /#{strategy.branch}$/
          git "checkout #{strategy.branch}"
        else
          git "checkout -b #{strategy.branch}"
        end

        # Always hard reset to whats on origin before merging master
        # in. When we create the branch - we may not have the latest commits.
        # This ensures that we do.
        git "reset origin/#{strategy.branch} --hard"
      end

      task "Merging your current branch #{colorize @previous_branch, :cyan} into #{colorize strategy.branch, :cyan}" do
        git "merge #{strategy.new_commit}"
      end
    end

    def after_deploy
      task "Pushing local #{colorize strategy.branch, :cyan} to #{colorize "origin", :cyan}"
      git "push -u origin #{strategy.branch} -v", :exec => true

      switch_back_to_old_branch
    end

    def rollback_before_deploy
      switch_back_to_old_branch
    end

    private

    def switch_back_to_old_branch
      task "Switching back to #{colorize @previous_branch, :cyan}" do
        git "checkout #{@previous_branch}"
      end
    end
  end
end
