class VoteRanking < ActiveRecord::Base  
	attr_accessible :title, :period, :name, :rank_type
	
	has_many :vote_ranking_tags

  belongs_to :reward
  
  def get_ranking_types
    RANKING_TYPES.map{|k,v| [v,k]}
  end
  
  def get_rank_type
    RANKING_TYPES[rank_type]
  end
  
end
