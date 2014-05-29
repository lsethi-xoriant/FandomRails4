class AddUniqueidToInstantwin < ActiveRecord::Migration
  def change
    add_column :instantwins, :unique_id, :string
  end
end
