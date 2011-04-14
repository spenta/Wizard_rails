class CreateAffiliationPlatforms < ActiveRecord::Migration
  def self.up
    create_table :affiliation_platforms do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :affiliation_platforms
  end
end
