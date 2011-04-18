class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers do |t|
      t.string :name
      t.text :logo_url

      t.timestamps
    end
  end

  def self.down
    drop_table :retailers
  end
end
