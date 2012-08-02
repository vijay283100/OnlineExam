class AddPassmarkToExamTable < ActiveRecord::Migration
  def self.up
    add_column :exams, :pass_mark, :integer
  end

  def self.down
    remove_column :exams, :pass_mark
  end
end
