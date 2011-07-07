class AddUrlToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :url, :string
  end

  def self.down
    remove_column :articles, :url
  end
end
