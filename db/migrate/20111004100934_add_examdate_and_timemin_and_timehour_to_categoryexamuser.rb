class AddExamdateAndTimeminAndTimehourToCategoryexamuser < ActiveRecord::Migration
  def self.up
    add_column :categoryexamusers, :time_hour, :integer, :default => 0
    add_column :categoryexamusers, :time_min, :integer, :default => 0
  end

  def self.down
    remove_column :categoryexamusers, :time_hour
    remove_column :categoryexamusers, :time_min
  end
end
