class UserCounter < ActiveRecord::Base
  
  # TODO: to be implemented (the current implementation is just meta code)
  def update_counters(user_interaction)
    update(correct_answer += 1, "TOTAL")
    if (updated_at.day == yesterday)
      update(correct_answer = 1, "DAILY")
    else
      update(correct_answer += 1, "DAILY")
    end
    
  end
end
