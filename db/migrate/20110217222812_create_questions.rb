class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :description
      t.integer :question_type_id
      t.integer :sort_order
      t.boolean :is_published
      t.boolean :is_shared
      t.integer :user_id
      t.integer :subject_id
      t.integer :image_id
      t.string  :name
      t.integer :parent_id
      t.integer :categorysubject_id
      t.float   :mark
      t.integer :feedback
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
 