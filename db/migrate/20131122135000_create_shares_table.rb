class CreateSharesTable < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.text :description
      t.string :message
      t.string :share_type
      t.timestamps
    end
  end
end
