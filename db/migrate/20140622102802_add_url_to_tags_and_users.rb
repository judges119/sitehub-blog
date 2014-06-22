class AddUrlToTagsAndUsers < ActiveRecord::Migration
  def change
    add_column :tags, :url, :string
    
    add_column :posts, :url, :string
  end
end
