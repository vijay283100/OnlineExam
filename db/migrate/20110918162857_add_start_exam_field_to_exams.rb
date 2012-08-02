class AddStartExamFieldToExams < ActiveRecord::Migration
  def self.up
    add_column :exams, :start_exam, :integer, :default => 0
  end

  def self.down
    remove_column :exams, :start_exam
  end
end
