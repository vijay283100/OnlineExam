class Categoryexamuser < ActiveRecord::Migration
  def self.up
    create_table :categoryexamusers do |t|
      t.primary_key :id
      t.references :categoryexam
      t.references :categoryuser
      t.integer :is_confirmed
      t.integer :has_attended, :default=>0
      t.integer :attempt
      t.datetime :exam_date
      t.string  :question_set
      t.timestamps
    end
  end

  def self.down
    drop_table :categoryexamusers
  end
end
