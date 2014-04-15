class CreateInteractionsTable < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :name
      t.integer :seconds, default: 0
      t.integer :points, default: 0
      t.integer :added_points, default: 0
      t.integer :cache_counter, default: 0
      t.string :when_show_interaction
      t.references :resource, polymorphic: true
      t.references :calltoaction
    end
  end
end
