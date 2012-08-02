class AddExamstarttimeToExams < ActiveRecord::Migration
  def self.up
add_column :exams, :examstart_time, :time
  end

  def self.down
remove_column :exams, :examstart_time
  end
end
