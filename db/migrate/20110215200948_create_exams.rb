class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.string :name
      t.string :exam_code
      t.datetime :exam_date
      t.time :total_time
      t.text :instruction
      t.string :exam_type
      t.integer :total_mark
      t.string :subject
      t.integer :organization_id
      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end
end
