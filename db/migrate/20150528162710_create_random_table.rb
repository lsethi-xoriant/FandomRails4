class CreateRandomTable < ActiveRecord::Migration
  def change
    create_table :random_resources do |t|
      t.text :tag
      t.timestamps
    end
  end
end