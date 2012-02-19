module TwitterOAuth
    class NoSuchHandleError < Exception; end
    class APIError          < Exception; end

    class Client
    alias :old_get :get
        def twitter_users(*lookup)
            ids = []
            sns = []

            return [] if lookup.empty?

            x = 0
            lookup.each do |l|
                # it's a twitter user ID
                if l.is_a?(Fixnum)
                    ids << l

                # it's an empty string, naughty
                elsif l.to_s.empty? or (l.to_s == '@')
                    raise BadHandleError, "Empty Twitter handle provided"

                # it's a twitter handle
                elsif l.to_s =~ /^\@?(\w+)$/
                    sns << $1
                end

                # max of 100 items in this API request
                break if (x += 1) == 100
            end

            # construct the query string for the API call
            qp = []
            qp << (ids.empty? ? nil : "user_id=#{ids.join(',')}")
            qp << (sns.empty? ? nil : "screen_name=#{sns.join(',')}")
            qs = qp.join('&')

            # get a response rather than return it directly
            response = get("/users/lookup.json?#{qs}")

            # translate API errors into a ruby exception
            if response.is_a?(Hash)
                errmsg = "API Errors:\n"
                response['errors'].each do |error|
                    errmsg += "  #{error['code']}: #{error['message']}\n"
                end
                raise APIError, errmsg
            end

            # no errors, return the response!
            response
        end
    end
end
