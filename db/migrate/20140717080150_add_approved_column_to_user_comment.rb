class AddApprovedColumnToUserComment < ActiveRecord::Migration
  def change
    add_column :user_comments, :approved, :boolean
  end
end
