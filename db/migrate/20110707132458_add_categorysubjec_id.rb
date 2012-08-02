class AddCategorysubjecId < ActiveRecord::Migration
  def self.up
add_column :subjectusers, :categorysubject_id, :integer
  end

  def self.down
remove_column :subjectusers, :categorysubject_id
  end
end
