# configure environment
ENV['RACK_ENV'] ||= 'development'
ENV['DB_NOLOG'] = 'true'

# require rake for creating tasks
require 'rake'

# load config.ru to get our app's setup
load File.expand_path('./config.ru', File.dirname(__FILE__))

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
        puts '<= db:down executed'
    end
end

namespace :admin do
    desc 'Add a blog administrator by Twitter handle'
    task :add, [:admin] do |t, args|
        v = args[:admin].to_s.strip
        raise 'No ADMIN account was provided' if v.empty?

        client = TwitterOAuth::Client.new
        rest_url = "/users/lookup.json?screen_name=#{v}"

        response = client.send(:get, rest_url)

        if response.is_a?(Hash) and response['errors']
            errstr = "API Errors:\n"
            response['errors'].each do |error|
                errstr += "  #{error['code']}: #{error['message']}"
            end
            raise errstr
        end

        id = response[0]['id']

        row = DB[:authors][:id => id]
        if row
            DB[:authors][:id => id] = {:administrator => true}
        else
            DB[:authors].insert(:id => id, :administrator => true)
        end
        puts '<= admin:add executed'
    end

    desc 'Remove a blog administrator by Twitter handle'
    task :remove, [:admin] do |t, args|
        v = args[:admin].to_s.strip
        raise 'No ADMIN account was provided' if v.empty?

        client = TwitterOAuth::Client.new
        rest_url = "/users/lookup.json?screen_name=#{v}"

        response = client.send(:get, rest_url)

        if response.is_a?(Hash) and response['errors']
            errstr = "API Errors:\n"
            respnse['errors'].each do |error|
                errstr += "  #{error['code']}: #{error['message']}"
            end
            raise errstr
        end

        id = response[0]['id']
        row = DB[:authors][:id => id]
        if row
            DB[:authors][:id => id] = {:administrator => false}
        end
        puts '<= admin:remove executed'
    end

    namespace :author do
        desc 'Add a blog author by Twitter handle'
        task :add, [:account] do |t, args|
            v = args[:account].to_s.strip
            raise 'No author ACCOUNT was provided' if v.empty?

            client = TwitterOAuth::Client.new
            rest_url = "/users/lookup.json?screen_name=#{v}"

            response = client.send(:get, rest_url)

            if response.is_a?(Hash) and response['errors']
                errstr = "API Errors:\n"
                respnse['errors'].each do |error|
                    errstr += "  #{error['code']}: #{error['message']}"
                end
                raise errstr
            end

            id = response[0]['id']
            unless DB[:authors][:id => id]
                DB[:authors].insert(:id => id)
            end
            puts '<= admin:author:add executed'
        end

        desc 'Remove a blog author by Twitter handle'
        task :remove, [:account] do |t, args|
            v = args[:account].to_s.strip
            raise 'No author ACCOUNT was provided' if v.empty?

            client = TwitterOAuth::Client.new
            rest_url = "/users/lookup.json?screen_name=#{v}"

            response = client.send(:get, rest_url)

            if response.is_a?(Hash) and response['errors']
                errstr = "API Errors:\n"
                respnse['errors'].each do |error|
                    errstr += "  #{error['code']}: #{error['message']}"
                end
                raise errstr
            end

            id = response[0]['id']
            if not DB[:posts].where(:author_id => id).empty?
                raise "Author #{v} has posts, will not execute.\n" +
                      "  (run admin:author:remove_cascade to remove all posts)"
            end
            DB[:authors].where(:id => id).delete
            puts '<= admin:author:remove executed'
        end

        desc 'Remove a blog author by Twitter handle - force'
        task :remove_cascade, [:account] do |t, args|
            v = args[:account].to_s.strip
            raise 'No author ACCOUNT was provided' if v.empty?

            client = TwitterOAuth::Client.new
            rest_url = "/users/lookup.json?screen_name=#{v}"

            response = client.send(:get, rest_url)

            if response.is_a?(Hash) and response['errors']
                errstr = "API Errors:\n"
                respnse['errors'].each do |error|
                    errstr += "  #{error['code']}: #{error['message']}"
                end
                raise errstr
            end

            id = response[0]['id']
            DB[:posts][:author_id => id].delete
            DB[:authors][:id => id].delete
            puts '<= admin:author:remove_cascade executed'
        end
    end
end
