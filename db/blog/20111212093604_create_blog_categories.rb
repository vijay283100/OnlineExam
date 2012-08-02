class CreateBlogCategories < ActiveRecord::Migration
  def self.up
    create_table :blog_categories do |t|
      t.string :name
      t.string :description
      t.integer :position, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :blog_categories
  end
end
