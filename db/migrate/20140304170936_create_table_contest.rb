class CreateTableContest < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.boolean :generated, :boolean, default: false
      t.string :title, :null => false
      t.datetime :start_date
      t.datetime :end_date
      t.references :property
      t.timestamps
    end
  end
end