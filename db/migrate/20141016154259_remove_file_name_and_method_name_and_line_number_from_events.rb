class RemoveFileNameAndMethodNameAndLineNumberFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :file_name
    remove_column :events, :method_name
    remove_column :events, :line_number
  end

  def down
    add_column :events, :line_number, :string
    add_column :events, :method_name, :string
    add_column :events, :file_name, :string
  end
end
