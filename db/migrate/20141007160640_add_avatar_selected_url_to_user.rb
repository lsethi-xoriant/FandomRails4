class AddAvatarSelectedUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_selected_url, :string
  end
end
