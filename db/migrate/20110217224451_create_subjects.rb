class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :name
      t.integer :category_id
      t.integer :organization_id
      t.timestamps
    end
      add_index :subjects, [ :name, :category_id ], :unique => true, :name => 'by_name_and_category'
  end 

  def self.down
    drop_table :subjects
  end
end
