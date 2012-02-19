Sequel.extension :pagination

class Post < Sequel::Model
    many_to_one  :author
    many_to_many :tags

    def self.page(tags, page, per)
        tags = *tags
        tags.collect! { |t| t.to_s }

        ed = Tag.join(:posts_tags, :tag_id => :id).filter do
            {
                :post_id => :id.qualify(:posts),
                :tag     => tags
            }
        end

        Post.where(ed.exists).order(:posted.desc).paginate(page, per)
    end
end
