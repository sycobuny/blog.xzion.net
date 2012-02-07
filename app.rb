enable :sessions
set :haml, :format => :html5

before do
    @title = 'An Oak in the Fall - XZion.net Blog'
end

get '/' do
    haml :index
end
