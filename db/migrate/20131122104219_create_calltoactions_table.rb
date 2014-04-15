class CreateCalltoactionsTable < ActiveRecord::Migration
  def change
    create_table :calltoactions do |t|
      t.string :title, null: false
      t.string :video_url
      t.string :media_type
      t.boolean :enable_disqus, default: false
      t.datetime :activated_at
      t.string :cta_template_type
      t.references :property
      t.timestamps
    end
  end
end
