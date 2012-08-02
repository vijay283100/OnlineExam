class CreateEvaluations < ActiveRecord::Migration
  def self.up
    create_table :evaluations do |t|
      t.integer :user_id
      t.integer :question_id
      t.integer :answer_id
      t.string  :fb_sequence
      t.integer :sort_order
      t.string  :answer_name
      t.boolean :has_attended, :default => false
      t.float   :question_mark
      t.float   :answer_mark
      t.integer :attempt
      t.integer :categoryexam_id
      t.integer :categoryuser_id
      t.timestamps
    end
  end

  def self.down
    drop_table :evaluations
  end
end
