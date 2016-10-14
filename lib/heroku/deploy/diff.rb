module Heroku::Deploy
  class Diff
    include Shell

    def self.diff(*args)
      new(*args)
    end

    attr_accessor :from, :to

    def initialize(from, to)
      @from = from
      @to   = to
    end

    def diff(folders)
      git %{diff #{from}..#{to} #{folders.join " "}}
    end

    def has_asset_changes?
      components = %w{api auth core marketing}
      folders = %w(app/assets lib/assets vendor/assets client Gemfile.lock)
      folders_to_check = folders
      folders_to_check += components.map {|c| folders.map {|f| "components/#{c}/#{f}"}}.flatten
      folders_that_exist = folders_to_check.select { |folder| File.exist?(folder) }

      diff(folders_that_exist).match /diff/
    end

    def has_migrations?
      migrations_diff.match /ActiveRecord::Migration/
    end

    def has_unsafe_migrations?
      migrations_diff.split("\n").any? do |line|
        has_unsafe_keyword?(line) && has_no_safe_override?(line)
      end
    end

    private

    def has_unsafe_keyword?(line)
      line.match(unsafe_migration_regexp)
    end

    def has_no_safe_override?(line)
      !line.match(safe_override_regexp)
    end

    def unsafe_migration_regexp
      /change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute|rename_table/
    end

    def safe_override_regexp
      /#\s*safe/
    end

    def migration_directories
      `find . -iname '*migrate'`.gsub(/\.\//, "").split(/\n/)
    end

    def migrations_diff
      diff migration_directories
    end
  end
end
