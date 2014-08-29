class RenameUserCommentToUserCommentInteraction < ActiveRecord::Migration
    def change
        rename_table :user_comments, :user_comment_interactions
    end 
end
