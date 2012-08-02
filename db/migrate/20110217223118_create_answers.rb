class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.string :name
      t.integer :question_id
      t.integer :is_answer
      t.integer :sort_order
      t.integer :image_id
      t.string  :fb_sequence
      t.string  :match_answer
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
