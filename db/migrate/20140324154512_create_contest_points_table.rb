class CreateContestPointsTable < ActiveRecord::Migration
  def change
    create_table :contest_points do |t|
    	t.integer :points
    	t.references :user
    	t.references :contest
    	t.timestamps
    end
  end
end
