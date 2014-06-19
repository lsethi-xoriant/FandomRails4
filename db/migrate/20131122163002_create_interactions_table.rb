class CreateInteractionsTable < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :name
      t.integer :seconds, default: 0
      t.integer :cache_counter, default: 0
      t.string :when_show_interaction
      t.references :resource, polymorphic: true
      t.references :call_to_action
    end
  end
end
