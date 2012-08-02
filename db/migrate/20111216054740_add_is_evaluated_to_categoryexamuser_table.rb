class AddIsEvaluatedToCategoryexamuserTable < ActiveRecord::Migration
  def self.up
    add_column :categoryexamusers, :has_evaluated, :integer, :default => 0
  end

  def self.down
    remove_column :categoryexamusers, :has_evaluated
  end
end
