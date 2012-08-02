class AddHourAndMinutefieldsToExamsTable < ActiveRecord::Migration
  def self.up
    add_column :exams, :time_hour, :integer, :default => 0
    add_column :exams, :time_min, :integer, :default => 0
  end

  def self.down
    remove_column :exams, :time_hour
    remove_column :exams, :time_min
  end
end
