class AddWonAndIwinteractionOnIntstantwins < ActiveRecord::Migration
  def change
    add_column :instantwins, :won, :boolean
    add_column :instantwins, :instantwin_interaction_id, :integer
  end
end
