class CreateUserInteractionsTable < ActiveRecord::Migration
  def change
    create_table :user_interactions do |t|
      t.references :user, :null => false
      t.references :interaction, :null => false
      t.references :answer
      t.integer :counter, default: 0
      t.timestamps
    end
  end
end
