class CreateSimpleChoices < ActiveRecord::Migration
  def self.up
    create_table :usage_choices do |t|
      t.float :weight_for_user
      t.references :usage
      t.references :user_request

      t.timestamps
    end
  end

  def self.down
    drop_table :usage_choices
  end
end
