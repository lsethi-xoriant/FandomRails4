class AddRegistrationNeededColumnToInteraction < ActiveRecord::Migration
  def change
    add_column :interactions, :registration_needed, :boolean
  end
end
