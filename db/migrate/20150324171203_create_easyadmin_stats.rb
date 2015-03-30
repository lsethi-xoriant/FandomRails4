class CreateEasyadminStats < ActiveRecord::Migration
  def change
    create_table :easyadmin_stats do |t|

      t.date :date

      t.timestamps
    end
    add_column :easyadmin_stats, :values, :json, default: '{}'
  end
end
