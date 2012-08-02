class AddPassFieldToCategoryexamusers < ActiveRecord::Migration
  def self.up
    add_column :categoryexamusers, :status, :string
  end

  def self.down
    remove_column :categoryexamusers, :status
  end
end
