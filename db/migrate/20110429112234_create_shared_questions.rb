class CreateSharedQuestions < ActiveRecord::Migration 
  def self.up
    create_table :shared_questions do |t|
      t.primary_key :id
      t.references :question
      t.references :user
      t.timestamps
    end
    add_index :shared_questions, [ :question_id, :user_id ], :unique => true, :name => 'by_question_and_user'

  end

  def self.down
    drop_table :shared_questions
  end
  
end
