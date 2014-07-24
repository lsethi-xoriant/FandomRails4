class ChangeParamsColumnInEvent < ActiveRecord::Migration
  def up
    change_table :events do |t|
      t.change :params, :text
    end
  end

  def down
    change_table :events do |t|
      t.change :params, :string
    end
  end
end
