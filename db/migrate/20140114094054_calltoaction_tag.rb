class CalltoactionTag < ActiveRecord::Migration
  def change
    create_table :calltoaction_tags do |t|
      t.references :calltoaction
      t.references :tag
      t.references :property
      t.timestamps
    end
  end
end