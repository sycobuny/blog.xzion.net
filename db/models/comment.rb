class Comment < Sequel::Model
    many_to_one :author
    many_to_one :parent, :class => Comment
end
