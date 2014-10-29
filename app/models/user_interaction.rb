include ApplicationHelper
include InstantwinHelper
include FandomUtils

class UserInteraction < ActiveRecord::Base
  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter, :like, :outcome, :aux

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode

  def is_answer_correct?
    answer.nil? || answer.correct
  end

  def mocked?
    false
  end
end

