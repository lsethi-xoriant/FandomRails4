class AddTagFieldsTable < ActiveRecord::Migration
  def change
    create_table :tag_fields do |t|
      t.references :tag
      t.string :name
      t.string :type
      t.text :value
    end
  end
end
