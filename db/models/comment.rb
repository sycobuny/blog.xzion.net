class Comment < Sequel::Model
    many_to_one :post
    many_to_one :parent,   :class => Comment, :key => :parent_id
    one_to_many :children, :class => Comment, :key => :parent_id

    def self.post_tree(id)
        comments = {}
        children = {}
        dataset.where(:post_id => id).each do |row|
            c = Comment.call(row)
            p = (children[c.parent_id] ||= [])
            comments[c.id] = c
            p << c
        end
    end

    def self.comment_tree(id)
        nonrecurse = dataset.select(*columns).where(:id => id.to_i)
        recurse    = dataset.select(*columns)

        join_args = {:id.qualify(:i) => :parent_id.qualify(:r)}
        recurve   = recurse.join(:r.as(:i), join_args)

        ds = db[:r].with_recursive(:r, nonrecurse, recurse, :args => columns)

        comments = {}
        children = {}
        ds.each do |row|
            c = Comment.call(row)
            p = (children[c.parent_id] ||= [])
            comments[c.id] = c
            p << c
        end
    end
end
