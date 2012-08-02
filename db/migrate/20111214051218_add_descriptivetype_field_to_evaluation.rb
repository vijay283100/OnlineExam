class AddDescriptivetypeFieldToEvaluation < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :descriptive_answer, :text
  end

  def self.down
    remove_column :evaluations, :descriptive_answer
  end
end
