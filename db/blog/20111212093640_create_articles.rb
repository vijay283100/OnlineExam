class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.integer :user_id
      t.text :title
      t.text :body_part
      t.integer :blog_category_id
      t.integer :subcategory_id
      t.integer :position, :default => 0
      t.boolean :enable_comment
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
