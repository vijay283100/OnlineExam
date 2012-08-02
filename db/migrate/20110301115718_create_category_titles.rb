class CreateCategoryTitles < ActiveRecord::Migration
  def self.up
    create_table :category_titles do |t|
      t.string :name
      t.integer :category_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :category_titles
  end
end
