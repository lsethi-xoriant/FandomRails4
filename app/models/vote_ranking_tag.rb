class VoteRankingTag < ActiveRecord::Base

  attr_accessible :tag_id, :vote_ranking_id

  belongs_to :tag
  belongs_to :vote_ranking
  
end