class CreateQuizTable < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :question, null: false
      t.integer :cache_correct_answer, default: 0
      t.integer :cache_wrong_answer, default: 0
      t.string :quiz_type
      t.timestamps
    end
  end
end
