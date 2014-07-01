class AddAnchorToHomeLaunchers < ActiveRecord::Migration
  def change
    add_column :home_launchers, :anchor, :boolean
  end
end
