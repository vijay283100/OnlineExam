class CreateFeedbackAnswers < ActiveRecord::Migration
  def self.up
    create_table :feedback_answers do |t|
      t.integer :feedback_id
      t.integer :question_id
      t.integer :answer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feedback_answers
  end
end
