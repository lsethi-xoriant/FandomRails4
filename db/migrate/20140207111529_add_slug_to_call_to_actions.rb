class AddSlugToCallToActions < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :slug, :string
    add_index :call_to_actions, :slug
  end
end
