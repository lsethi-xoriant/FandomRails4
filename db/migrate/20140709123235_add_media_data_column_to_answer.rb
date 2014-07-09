class AddMediaDataColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :media_data, :text
  end
end
