class RemoveCorrectAnswerFromUserCounter < ActiveRecord::Migration
  def up
    remove_column :user_counters, :correct_answer
  end

  def down
    add_column :user_counters, :correct_answer, :integer
  end
end
