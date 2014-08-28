class RemovePlayFromUserCounter < ActiveRecord::Migration
  def up
    remove_column :user_counters, :play
  end

  def down
    add_column :user_counters, :play, :integer
  end
end
