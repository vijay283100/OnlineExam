class CreateCategoryExams < ActiveRecord::Migration
  def self.up
    create_table :categoryexams do |t|
      t.primary_key :id
      t.references :category
      t.references :exam
      t.integer    :examtype_id
      t.string     :currentyear
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :categoryexams
  end
end
