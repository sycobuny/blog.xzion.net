class Tag < Sequel::Model
    many_to_many :posts

    def self.resolve(tags)
        objs = []
        tags = tags.dup

        dataset.filter(:tag => tags).each do |tag|
            objs << tag
            tags.delete(tag.tag)
        end

        return objs if tags.empty?

        dataset.returning('*'.lit).import([:tag], [tags]).each do |tag|
            objs << tag
            tags.delete(tag)
        end

        return objs
    end
end
