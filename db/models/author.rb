class Author < Sequel::Model
    one_to_many :posts

    def self.flush_cache!
        @@twitter_ids     = {}
        @@twitter_handles = {}
    end

    def self.cache(type = :ids)
        if type == :ids
            @@twitter_ids    ||= {}
        elsif type == :handles
            @twitter_handles ||= {}
        else
            {}
        end
    end

    def self.twitter_users(*lookup)
        ret = {}

        # this checks our cache of users. it's a lambda cause we have to call
        # it twice.
        lamb = lambda do |l, i|
            # it's a user ID
            if l.is_a?(Fixnum) and (u = cache(:ids)[l])
                ret[l] = u
                lookup.delete_at(i)
            # it's a twitter handle
            elsif l =~ /^\@(\w+)$/ and (u = cache(:handles)[$1])
                ret[$1] = u
                lookup.delete_at(i)
            # anything else, we're punting to TwitterOAuth.
            end
        end

        # check the cache first before doing anything else.
        lookup.dup.each_with_index(&lamb)

        # this means we found everyone in the cache, no need to hit the API.
        return ret if lookup.empty?

        # populate the cache cause we still have looking up to do.
        begin
            client = TwitterOAuth::Client.new
            client.twitter_users(*lookup).each do |user|
                cache(:ids    )[user['id']         ] = user
                cache(:handles)[user['screen_name']] = user
            end

            lookup.dup.each_with_index(&lamb)
        # just feeling lazy, don't want to handle any errors right now.
        rescue BasicObject; end

        # return what we could find. for now, leave it to users to detect if
        # there are any missing entries.
        return ret
    end
end
