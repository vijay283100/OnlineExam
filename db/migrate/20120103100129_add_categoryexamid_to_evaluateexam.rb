class AddCategoryexamidToEvaluateexam < ActiveRecord::Migration
  def self.up
    add_column :evaluate_exams, :categoryexam_id, :integer
  end

  def self.down
    remove_column :evaluate_exams, :categoryexam_id
  end
end
