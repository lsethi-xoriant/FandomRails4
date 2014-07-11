class CreateReleasingTable < ActiveRecord::Migration
  def change
    create_table :releasing_files do |t|
      t.references :call_to_action, :null => false
      t.timestamps
    end
  end
end
