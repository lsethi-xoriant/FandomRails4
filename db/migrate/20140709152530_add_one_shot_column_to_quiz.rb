class AddOneShotColumnToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :one_shot, :boolean, default: true
  end
end
