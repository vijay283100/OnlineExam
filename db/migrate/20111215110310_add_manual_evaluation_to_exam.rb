class AddManualEvaluationToExam < ActiveRecord::Migration
  def self.up
    add_column :exams, :manual_evaluation, :integer, :default => 0
  end

  def self.down
    remove_column :exams, :manual_evaluation
  end
end
