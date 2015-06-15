class AddAnonymousIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :anonymous_id, :string, default: nil
    add_index :users, :anonymous_id
  end
end
