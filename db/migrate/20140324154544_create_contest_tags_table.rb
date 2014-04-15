class CreateContestTagsTable < ActiveRecord::Migration
  def change
    create_table :contest_tags do |t|
    	t.references :tag
    	t.references :contest
    	t.timestamps
    end
  end
end
