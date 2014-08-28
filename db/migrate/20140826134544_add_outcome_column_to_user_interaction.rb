class AddOutcomeColumnToUserInteraction < ActiveRecord::Migration
  def change
    add_column :user_interactions, :outcome, :text
  end
end
