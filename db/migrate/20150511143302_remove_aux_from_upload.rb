class RemoveAuxFromUpload < ActiveRecord::Migration
  def up
    remove_column :uploads, :aux
  end

  def down
    add_column :uploads, :aux, :json
  end
end
