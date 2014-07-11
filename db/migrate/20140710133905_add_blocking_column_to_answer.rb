class AddBlockingColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :blocking, :boolean, default: false
  end
end
