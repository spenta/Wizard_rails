class CreateTagArticleAssociations < ActiveRecord::Migration
  def self.up
    create_table :tag_article_associations do |t|
      t.references :tag
      t.references :article

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_article_associations
  end
end
