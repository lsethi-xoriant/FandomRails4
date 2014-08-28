class AddRankTypeToRanking < ActiveRecord::Migration
  def change
    add_column :rankings, :rank_type, :string
    add_column :rankings, :people_filter, :string
  end
end
