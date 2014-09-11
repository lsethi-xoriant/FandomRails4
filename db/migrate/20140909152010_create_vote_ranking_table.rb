class CreateVoteRankingTable < ActiveRecord::Migration
  def change
    create_table :vote_rankings do |t|
      t.string :name
      t.string :title
      t.string :period
      t.string :rank_type
      t.timestamps
    end
  end
end
