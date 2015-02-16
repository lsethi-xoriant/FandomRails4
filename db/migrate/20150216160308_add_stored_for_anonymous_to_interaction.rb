class AddStoredForAnonymousToInteraction < ActiveRecord::Migration
  def change
    add_column :interactions, :stored_for_anonymous, :boolean
  end
end
