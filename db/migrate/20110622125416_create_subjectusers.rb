class CreateSubjectusers < ActiveRecord::Migration
  def self.up
    create_table :subjectusers do |t|
      t.primary_key :id
      t.integer :subject_id
      t.integer :user_id

      t.timestamps
    end
    
  end

  def self.down
    drop_table :subjectusers
  end
end
