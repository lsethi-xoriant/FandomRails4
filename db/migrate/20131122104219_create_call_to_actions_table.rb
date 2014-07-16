class CreateCallToActionsTable < ActiveRecord::Migration
  def change
    create_table :call_to_actions do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :video_url
      t.string :media_type
      t.boolean :enable_disqus, default: false
      t.datetime :activated_at
      t.string :secondary_id
      t.timestamps
    end
    add_index :call_to_actions, :name, :unique => true
  end
end
