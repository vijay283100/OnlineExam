class AddEvaluateToEvaluationsTable < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :evaluate, :integer, :default => 0
  end

  def self.down
    remove_column :evaluations, :evaluate
  end
end
