class AddNeedEvaluationToCategoryexamuser < ActiveRecord::Migration
  def self.up
    add_column :categoryexamusers, :need_evaluation, :integer, :default => 0
  end

  def self.down
    remove_column :categoryexamusers, :need_evaluation
  end
end
