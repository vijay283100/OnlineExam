class CreateClientImages < ActiveRecord::Migration
  def self.up
    create_table :client_images do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :client_images
  end
end
