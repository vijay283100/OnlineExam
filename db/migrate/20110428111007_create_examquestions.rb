class CreateExamquestions < ActiveRecord::Migration
def self.up
    create_table :examquestions do |t|
      t.primary_key :id
      t.references :exam
      t.references :question
      t.timestamps
    end
    add_index :examquestions, [ :exam_id, :question_id ], :unique => true, :name => 'by_exam_and_question'

  end

  def self.down
    drop_table :examquestions
  end
end
