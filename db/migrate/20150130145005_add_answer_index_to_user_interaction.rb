class AddAnswerIndexToUserInteraction < ActiveRecord::Migration
  def change
    add_index :user_interactions, :answer_id
  end
end