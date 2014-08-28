class Ranking < ActiveRecord::Base  
	attr_accessible :title, :period, :reward_id, :name, :rank_type, :people_filter

  belongs_to :reward
  
  def get_ranking_types
    RANKING_TYPES.map{|k,v| [v,k]}
  end
  
  def get_rank_type
    RANKING_TYPES[rank_type]
  end
  
end
