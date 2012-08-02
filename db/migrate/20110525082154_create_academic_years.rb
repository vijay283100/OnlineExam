class CreateAcademicYears < ActiveRecord::Migration
  def self.up
    create_table :academic_years do |t|
      t.string :name
	 t.integer :organization_id
      t.timestamps
    end
  end

  def self.down
    drop_table :academic_years
  end
end
