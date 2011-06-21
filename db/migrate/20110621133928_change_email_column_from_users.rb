class ChangeEmailColumnFromUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :email, :name
  end

  def self.down
    rename_column :users, :name, :email
  end
end
