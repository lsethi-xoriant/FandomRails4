class AddExtraFieldsColumnToVote < ActiveRecord::Migration
  def change
    add_column :votes, :extra_fields, :json
  end
end
