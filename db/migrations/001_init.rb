Sequel.migration do
    change do
        create_table :authors do
            Integer   :id,            :null => false
            TrueClass :administrator, :null => false, :default => false

            primary_key [:id]
        end

        create_table :posts do
            primary_key :id

            Integer  :author_id
            DateTime :posted, :null => false, :default => :now.sql_function()
            String   :title,  :null => false
            String   :body,   :null => false
            String   :preview, :null => false 
            String   :slug,   :unique => true

            foreign_key [:author_id], :authors
        end

        create_table :tags do
            primary_key :id

            String :tag
        end

        create_table :comments do
            primary_key :id

            DateTime :posted,  :null => false, :default => :now.sql_function()
            String   :title,   :null => false
            String   :body,    :null => false
            Integer  :post_id, :null => false
            Integer  :parent_id
            Integer  :author_id

            foreign_key [:post_id],   :posts
            foreign_key [:parent_id], :comments
        end

        create_table :posts_tags do
            Integer :post_id, :null => false
            Integer :tag_id,  :null => false

            foreign_key [:post_id], :posts
            foreign_key [:tag_id],  :tags

            primary_key [:post_id, :tag_id]
        end
    end
end
