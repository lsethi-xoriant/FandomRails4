class AddTitleNeededToUpload < ActiveRecord::Migration
  def change
    add_column :uploads, :title_needed, :boolean, default: false
  end
end
