class CreateTagsTagsTable < ActiveRecord::Migration
  def change
    create_table :tags_tags do |t|
      t.integer :tag_id
      t.integer :belongs_tag_id
    end
  end
end
