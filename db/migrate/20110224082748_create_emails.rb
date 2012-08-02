class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.text :content
      t.string :section_id
      t.text :help_content
      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
