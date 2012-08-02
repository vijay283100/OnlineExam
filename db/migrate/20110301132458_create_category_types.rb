class CreateCategoryTypes < ActiveRecord::Migration
  def self.up
    create_table :category_types do |t|
      t.string :title
      t.integer :organization_id
      t.integer :sort_order

      t.timestamps
    end
  end

  def self.down
    drop_table :category_types
  end
end
