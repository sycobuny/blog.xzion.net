enable :sessions
set :haml, :format => :html5

before do
    @title = 'An Oak in the Fall - XZion.net Blog'
end

get '/styles.css' do
    sass :styles
end

get '/' do
    haml :index
end
