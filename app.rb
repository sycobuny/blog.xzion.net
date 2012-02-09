enable :sessions
set :haml, :format => :html5

Dir.glob('app/*.rb').each { |fn| require fn }

get '/styles.css' do
    sass :styles
end

get '/' do
    haml :index
end
