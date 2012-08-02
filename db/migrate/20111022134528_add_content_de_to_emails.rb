class AddContentDeToEmails < ActiveRecord::Migration
  def self.up
    add_column :emails, :content_de, :text
  end

  def self.down
    remove_column :emails, :content_de
  end
end
