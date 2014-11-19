class AddInstantWinInteractionTable < ActiveRecord::Migration
  def change
    create_table :instantwin_interactions do |t|
      t.references :reward, :null => false
      t.timestamps
    end
  end
end
