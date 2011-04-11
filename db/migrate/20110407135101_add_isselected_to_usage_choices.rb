class AddIsselectedToUsageChoices < ActiveRecord::Migration
  def self.up
    add_column :usage_choices, :is_selected, :boolean
  end

  def self.down
    remove_column :usage_choices, :is_selected
  end
end
