class AddResultPendingToExamResultTable < ActiveRecord::Migration
  def self.up
    add_column :exam_results, :result_pending, :integer, :default => 0
  end

  def self.down
    remove_column :exam_results, :result_pending
  end
end
