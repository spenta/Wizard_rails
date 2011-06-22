class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.text :title
      t.text :meta
      t.text :summary
      t.text :body
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
