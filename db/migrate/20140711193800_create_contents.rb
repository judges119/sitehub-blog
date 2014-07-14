class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :post_id
      t.integer :position
      t.text :content
      t.string :picture

      t.timestamps
    end
  end
end
