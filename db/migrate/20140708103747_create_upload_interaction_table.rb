class CreateUploadInteractionTable < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.references :call_to_actions, :null => false
      t.boolean :releasing
      t.text :releasing_description
      t.boolean :privacy
      t.text :privacy_description
      t.timestamps
    end
    add_index :answers, :quiz_id
  end
end
