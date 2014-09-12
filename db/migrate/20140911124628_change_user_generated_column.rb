class ChangeUserGeneratedColumn < ActiveRecord::Migration
  def change
    remove_column :call_to_actions, :user_generated
    #add_column :call_to_actions, :user_id, :integer
  end
end
