class CreateHomeLauncherTable < ActiveRecord::Migration
  def change
    create_table :home_launchers do |t|
      t.text :description
      t.string :button
      t.string :url
      t.boolean :enable, default: true
      t.timestamps
    end
  end
end
