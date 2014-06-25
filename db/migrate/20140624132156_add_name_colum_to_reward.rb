class AddNameColumToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :name, :string
    add_index :rewards, :name, :unique => true
  end
end
