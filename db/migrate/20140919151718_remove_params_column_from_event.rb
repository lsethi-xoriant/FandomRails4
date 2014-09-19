class RemoveParamsColumnFromEvent < ActiveRecord::Migration
  def up
    remove_column :events, :params
  end

  def down
    add_column :events, :params, :string
  end
end