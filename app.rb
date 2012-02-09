enable :sessions
set :haml, :format => :html5

Dir.glob('app/*.rb').each { |fn| require fn }

before do
    @logged_in = session[:logged_in]
    @client = TwitterOAuth::Client.new(
        :consumer_key    => ENV['TWITTER_OAUTH_KEY'],
        :consumer_secret => ENV['TWITTER_OAUTH_SECRET'],
        :token           => session[:access_token],
        :secret          => session[:secret_token]
    )
    @rate_limit_status = @client.rate_limit_status
end

get '/styles.css' do
    sass :styles
end

get '/' do
    haml :index
end

get '/login' do
    host = request.env['SERVER_NAME'].to_s
    port = request.env['SERVER_PORT'].to_s

    if (!port.empty?) and (port != '80')
        server = "#{host}:#{port}"
    else
        server = host
    end

    callback_url = "http://#{server}/twitter_authed"

    request_token = @client.request_token(
        :oauth_callback => callback_url
    )

    session[:request_token]        = request_token.token
    session[:request_token_secret] = request_token.secret

    redirect request_token.authorize_url.gsub('authorize', 'authenticate')
end

get '/twitter_authed' do
    begin
        @access_token = @client.authorize(
            session[:request_token],
            session[:request_token_secret],
            :oauth_verifier => params[:oauth_verifier]
        )
    rescue OAuth::Unauthorized
    end

    if @client.authorized?
        session[:access_token] = @access_token.token
        session[:secret_token] = @access_token.secret
        session[:logged_in]    = true
    end

    redirect '/'
end

get '/logout' do
    session[:logged_in]            = nil
    session[:request_token]        = nil
    session[:request_token_secret] = nil
    session[:access_token]         = nil
    session[:secret_token]         = nil

    redirect '/'
end
