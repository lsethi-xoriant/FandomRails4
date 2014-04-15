class CreateAnswersTable < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :quiz, :null => false
      t.string :text, :null => false
      t.boolean :correct
      t.boolean :remove_answer, default: false
      t.timestamps
    end
    add_index :answers, :quiz_id
  end
end
