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

    unless ($last_query_time.to_i + 10) >= Time.now.to_i
        client = TwitterOAuth::Client.new
        $twitter = client.search('from:sycobuny+exclude:retweets')
        $last_query_time = Time.now.to_i
    end
end

get '/styles.css' do
    sass :styles
end

get '/' do
    @posts = Post.page(@default_tag, 1, 5).all
    @title = @blog_title
    haml :index
end

get '/posts/new' do
    unless @logged_in
        unless Author[@client.info[:id]]
            return 403
        end
    end

    @post = Post.new
    haml :'forms/post'
end

post '/posts/save' do
    id   = params.delete('id')
    tags = params.delete('tags')

    body = params[:body]
    body.gsub!(/(.*)\#\{END_PREVIEW\} ?(.*)/m, "\\1\\2")
    if $1 and $2
        params['preview'] = $1
    else
        body_parts = body.split("\n")

        preview_parts = []
        graphs = 0
        body_parts.each do |l|
            preview_parts << l
            graphs += 1 if (l =~ /[^\r]/)
            break if (graphs == 3)
        end

        params['preview'] = preview_parts.join("\n")
    end

    tags = tags.to_s.split(',').collect { |t| t.strip }.uniq
    tags << @default_tag unless tags.index(@default_tag)
    tags = Tag.resolve(tags)

    params['author_id'] = @client.info['id']

    if id
        Post.dataset[:id => id] = params
        post = Post[id]
    else
        post = Post.new(params)
        post.save
    end

    tags.each do |tag|
        post.add_tag(tag) unless post.tags.find { |t| t.id == tag.id }
    end
    post.save

    redirect "/posts/#{post.slug}"
end

get '/posts/:id/edit' do
    @post = Post[params[:id]]

    return 404 unless @post

    haml :'forms/post'
end

get '/posts/:id/delete' do
    @post = Post[params[:id]]
    return 404 unless @post
    haml :'forms/delete_post'
end

post '/posts/:id/delete' do
    post = Post[params[:id]]
    return 404 unless post
    post.delete

    redirect '/'
end

get '/posts/:slug' do
    @post = Post.where(:slug => params[:slug]).first

    unless @post
        @post = Post[params[:slug].to_i]
    end

    not_found unless @post

    @title = "#{@post.title} - #{@blog_title}"
    haml :post
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
