class CreateInteractionsTable < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :name
      t.integer :seconds, default: 0
      t.string :when_show_interaction
      t.boolean :required_to_complete
      t.references :resource, polymorphic: true
      t.references :call_to_action
    end
    add_index :interactions, :name, :unique => true
  end
end
