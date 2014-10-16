class RemoveRemoveAnswerFromAnswer < ActiveRecord::Migration
  
  def up
    remove_column :answers, :remove_answer
  end
  
  def down
    add_column :answers, :remove_answer, :boolean
  end

end
