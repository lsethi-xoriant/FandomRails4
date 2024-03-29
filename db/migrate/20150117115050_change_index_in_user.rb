class ChangeIndexInUser < ActiveRecord::Migration
  def up
    remove_index :users, :username
    add_index :users, :username
  end

  def down
    remove_index :users, :username
    add_index :users, :username, unique: true
  end
end
