class AddLikeColumnToUserInteraction < ActiveRecord::Migration
  def change
    add_column :user_interactions, :like, :boolean
  end
end
