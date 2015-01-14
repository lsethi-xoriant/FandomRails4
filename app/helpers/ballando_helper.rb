module BallandoHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes({ :reward_tags => :tag }).where("tags.name = 'superfan' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end
  
  def is_special_guest_active
    setting = cache_short(get_special_guest_settings_key) do 
      Setting.find_by_key("ballando_special_guest")
    end
    !setting.nil? && setting.value.downcase == "si"
  end
  
  def expire_gigya_url_cache_key
    expire_cache_key 'gigya.url'
  end
  
  def gigya_url
    cache_short 'gigya.url' do
      rows = Setting.where(key: 'gigya.url').select('value')
      if rows.count > 0 && rows[0].value.strip.length > 0
        rows[0].value
      else
        "http://cdn.gigya.com/js/socialize.js"
      end
    end
  end
  
end