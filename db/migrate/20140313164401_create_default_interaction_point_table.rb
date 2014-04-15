class CreateDefaultInteractionPointTable < ActiveRecord::Migration
  def change
    create_table :default_interaction_points do |t|
      t.integer :points, default: 0
      t.integer :added_points, default: 0
      t.string :interaction_type
      t.references :property
      t.timestamps
    end
  end
end
