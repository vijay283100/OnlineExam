class CreateCategorysubjects < ActiveRecord::Migration
  def self.up
    create_table :categorysubjects do |t|
      t.references :category
      t.references :subject
      t.timestamps
    end
    add_index :categorysubjects, [ :category_id, :subject_id ], :unique => true, :name => 'by_category_and_subject'

  end

  def self.down
    drop_table :categorysubjects
  end
end
