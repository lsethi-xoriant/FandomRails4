class FixCacheVotesJsonColumnName < ActiveRecord::Migration
  def change
    rename_column :cache_votes, :aux, :data
  end
end
