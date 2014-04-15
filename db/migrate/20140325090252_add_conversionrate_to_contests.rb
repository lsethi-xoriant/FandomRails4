class AddConversionrateToContests < ActiveRecord::Migration
  def change
    add_column :contests, :conversion_rate, :integer, :default => 1
  end
end
