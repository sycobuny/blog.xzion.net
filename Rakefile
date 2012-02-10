$LOAD_PATH.unshift File.expand_path('.', File.dirname(__FILE__))
require 'rake'
require 'sequel'
require 'db/config'

namespace :db do
    desc 'Perform automigration (reset your db)'
    task :auto do
        Sequel.extension :migration
        Sequel::Migrator.run DB, MIGRATIONS_DIR, :target => 0
        Sequel::Migrator.run DB, MIGRATIONS_DIR
        puts '<= db:auto executed'
    end

    desc 'Perform migration up/down to VERSION'
    task :to, [:version] do |t, args|
        v = (args[:version] || ENV['VERSION']).to_s.strip
        raise 'No VERSION was provided' if v.empty?

        Sequel.extension :migration
        Sequel::Migrator.apply DB, MIGRATIONS_DIR, :target => v.to_i
        puts "<= db:to[#{v}] executed"
    end

    desc 'Perform migration up to the latest version available'
    task :up do
        Sequel.extension :migration
        Sequel::Migrator.run DB, MIGRATIONS_DIR
        puts '<= db:up executed'
    end

    desc 'Perform migration down (erase all data)'
    task :down do
        Sequel.extension :migration
        Sequel::Migrator.run DB, MIGRATIONS_DIR, :target => 0
    end
end
