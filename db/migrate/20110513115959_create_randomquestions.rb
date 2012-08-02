class CreateRandomquestions < ActiveRecord::Migration
  def self.up
    create_table :randomquestions do |t|
      t.integer :exam_id
      t.string :question_set

      t.timestamps
    end
  end

  def self.down
    drop_table :randomquestions
  end
end
