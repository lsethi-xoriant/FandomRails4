class AddMediaTypeColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :media_type, :string
  end
end
