class CreateBasicTable < ActiveRecord::Migration
  def change
    create_table :basics do |t|
      t.text :basic_type
      t.timestamps
    end
  end
end