class AddTitleForHeadToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :title_for_head, :text
  end

  def self.down
    remove_column :articles, :title_for_head
  end
end
