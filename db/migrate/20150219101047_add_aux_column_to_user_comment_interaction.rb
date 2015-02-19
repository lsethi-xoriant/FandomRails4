class AddAuxColumnToUserCommentInteraction < ActiveRecord::Migration
  def change
    add_column :user_comment_interactions, :aux, :json
  end
end
