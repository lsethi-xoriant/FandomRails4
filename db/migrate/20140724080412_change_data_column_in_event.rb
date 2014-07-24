class ChangeDataColumnInEvent < ActiveRecord::Migration
  def up
    change_table :events do |t|
      t.change :data, :text
    end
  end

  def down
    change_table :events do |t|
      t.change :data, :string
    end
  end
end