class AddSidebarToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :sidebar, :text
  end

  def self.down
    remove_column :articles, :sidebar, :text
  end
end
