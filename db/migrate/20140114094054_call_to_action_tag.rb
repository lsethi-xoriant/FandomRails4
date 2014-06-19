class CallToActionTag < ActiveRecord::Migration
  def change
    create_table :call_to_action_tags do |t|
      t.references :call_to_action
      t.references :tag
      t.timestamps
    end
  end
end