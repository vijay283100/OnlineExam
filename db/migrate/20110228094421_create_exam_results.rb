class CreateExamResults < ActiveRecord::Migration
  def self.up
    create_table :exam_results do |t|
      t.integer :categoryexam_id
      t.integer :categoryuser_id
      t.float :score
      t.string :status
      t.integer :attempt
      t.float   :total_mark
      t.float   :percent
      t.string  :examname
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_results
  end
end
