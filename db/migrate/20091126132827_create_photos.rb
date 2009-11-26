class CreatePhotos < ActiveRecord::Migration
  
  def self.up
    create_table :photos do |t|
      t.string  :url, :null => false
      t.string  :thumb_url, :null => false
      t.integer :assignment_id
      t.integer :photog_id
      t.timestamps
    end
    add_index :photos, %w(assignment_id photog_id), :unique => true
    add_index :photos, :photog_id
  end

  def self.down
    drop_table :photos
  end
end