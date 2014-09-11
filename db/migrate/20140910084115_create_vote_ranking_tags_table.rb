class CreateVoteRankingTagsTable < ActiveRecord::Migration
  def change
    create_table :vote_ranking_tags do |t|
      t.references :tag
      t.references :vote_ranking
      t.timestamps
    end
  end
end
