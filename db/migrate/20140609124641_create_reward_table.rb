class CreateRewardTable < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :title
      t.text :short_description
      t.text :long_description
      t.string :button_label
      t.integer :cost
      t.datetime :valid_from
      t.datetime :valid_to
      t.string :video_url
      t.string :media_type
      t.integer :currency_id
      t.boolean :spendable
      t.boolean :countable
      t.boolean :numeric_display
      t.string :name
      t.timestamps
    end    
    add_index :rewards, :name, :unique => true
  end
end
