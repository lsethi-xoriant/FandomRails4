class CreateReleasingTable < ActiveRecord::Migration
  def change
    create_table :releasing_files do |t|
      t.timestamps
    end
  end
end
