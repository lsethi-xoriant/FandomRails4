class RemoveUniqueidColumnFromInstantwin < ActiveRecord::Migration
  def change
    remove_column :instantwins, :unique_id
  end
end
