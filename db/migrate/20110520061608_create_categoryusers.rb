class CreateCategoryusers < ActiveRecord::Migration
  def self.up
    create_table :categoryusers do |t|
      t.primary_key :id
      t.references :category
      t.references :user
      t.string     :currentyear
      t.timestamps
    end
    
  end

  def self.down
    drop_table :categoryusers
  end
end
