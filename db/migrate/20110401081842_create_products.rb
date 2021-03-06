class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name
      t.string :small_img_url
      t.string :big_img_url

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
