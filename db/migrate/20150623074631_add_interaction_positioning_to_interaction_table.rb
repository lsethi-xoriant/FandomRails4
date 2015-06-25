class AddInteractionPositioningToInteractionTable < ActiveRecord::Migration
  def change
    add_column :interactions, :interaction_positioning, :string
  end
end
