module BallandoHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes({:reward_tags => { :tag => :tag_fields }}).where("tags.name = 'superfan' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end
  
  def is_special_guest_active
    setting = cache_short(get_special_guest_settings_key) do 
      Setting.find_by_key("ballando_special_guest")
    end
    !setting.nil? && setting.value.downcase == "si"
  end
  
end