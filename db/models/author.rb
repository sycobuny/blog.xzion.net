class Author < Sequel::Model
    one_to_many :posts
    one_to_many :comments
end
