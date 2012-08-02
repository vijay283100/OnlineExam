class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :article_id
      t.string :name
      t.string :url
      t.text :comment
      t.time :comment_time
      t.integer :user_id
      t.integer :comment_level
      t.integer :parent_comment_id
      t.integer :is_deleted, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
