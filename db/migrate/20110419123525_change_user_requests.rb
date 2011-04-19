class ChangeUserRequests < ActiveRecord::Migration
  def self.up
    drop_table :user_requests
    create_table :user_requests do |t|
      t.boolean :is_complete
      t.timestamps
    end
  end

  def self.down
    drop_table :user_requests
    create_table :user_requests do |t|
      t.string :order_by
      t.integer :num_result
      t.integer :start_index

      t.timestamps
    end
  end
end

