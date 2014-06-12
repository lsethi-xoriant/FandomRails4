class CreateRewardTagsTable < ActiveRecord::Migration
  def change
    create_table :reward_tags do |t|
      t.references :tag
      t.references :reward
      t.timestamps
    end
  end
end
