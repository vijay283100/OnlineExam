class CreateArticleRatings < ActiveRecord::Migration
  def self.up
    create_table :article_ratings do |t|
      t.integer :user_id
      t.integer :article_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :article_ratings
  end
end
