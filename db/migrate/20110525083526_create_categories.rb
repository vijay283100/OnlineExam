class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.integer :course_id
      t.integer :academic_year_id
      t.integer :section_id
      t.integer :department_id
      t.integer :semester_id
      t.integer :organization_id
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
