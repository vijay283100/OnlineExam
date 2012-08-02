class ChangeStringToTextInQuestionsTable < ActiveRecord::Migration
  def self.up
    change_column :questions, :description, :text
  end

  def self.down
  end
end
