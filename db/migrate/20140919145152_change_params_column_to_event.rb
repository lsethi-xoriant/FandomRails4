class ChangeParamsColumnToEvent < ActiveRecord::Migration
  def up
    change_table :events do |t|
      t.change :params, :string
    end
  end

  def down
    change_table :events do |t|
      t.change :params, :text
    end
  end
end
