class CreateInteractionCallToActionTable < ActiveRecord::Migration
  def change
    create_table :interaction_call_to_actions do |t|
      t.references :interaction
      t.references :call_to_action
      t.column :condition, :json
      t.timestamps
    end
    add_index :interaction_call_to_actions, :interaction_id
    add_index :interaction_call_to_actions, :call_to_action_id
    add_index :interaction_call_to_actions, [:interaction_id, :call_to_action_id], name: 'index_interaction_ctas_on_interaction_id_and_cta_id'
  end
end
