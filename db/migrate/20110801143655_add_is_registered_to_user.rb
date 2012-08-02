class AddIsRegisteredToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_registered, :integer, :default => 0
  end

  def self.down
    remove_column :users, :is_registered
  end
end
