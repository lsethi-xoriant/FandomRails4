class CreateTagsTagsTable < ActiveRecord::Migration
  def change
    create_table :tags_tags do |t|
      t.integer :tag_id
      t.integer :belongs_tag_id
      t.timestamps
    end
    add_index :tags_tags, :tag_id
    add_index :tags_tags, :belongs_tag_id
  end
end
