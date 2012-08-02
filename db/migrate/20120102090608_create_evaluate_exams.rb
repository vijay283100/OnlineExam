class CreateEvaluateExams < ActiveRecord::Migration
  def self.up
    create_table :evaluate_exams do |t|
      t.integer :exam_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :evaluate_exams
  end
end
