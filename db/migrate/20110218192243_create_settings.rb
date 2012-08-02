class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.boolean  :allow_examinee_registration, :default => false
      t.boolean  :confirm_exam, :default => false
      t.string   :datetime_format
      t.string   :locale
      t.integer  :organization_id
      t.integer  :examineeApprove, :default => 0
      t.string   :url
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
