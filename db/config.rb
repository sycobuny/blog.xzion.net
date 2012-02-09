MIGRATIONS_DIR = File.expand_path('migrations', File.dirname(__FILE__))

if ENV['DATABASE_URL'] and not ENV['DATABASE_URL'].empty?
    DB = Sequel.connect(ENV['DATABASE_URL'])
else
    require 'psych'
    require 'yaml'

    opts = YAML.load_file('db/config.yaml')
    db_opts = {}
    opts.each do |key, value|
        db_opts[key.to_sym] = value
    end

    DB = Sequel.connect(db_opts)

    require 'logger'
    DB.loggers << Logger.new(STDOUT)
end

model_dir = File.expand_path('models', File.dirname(__FILE__))
Dir.glob("#{model_dir}/**/*.rb").each do |file|
    require file
end
