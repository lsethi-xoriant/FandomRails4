class CreateDownloadsTable < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.string :title, :null => false
      t.timestamps
    end
  end
end
