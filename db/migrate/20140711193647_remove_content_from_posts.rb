class RemoveContentFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :content, :text
  end
end
