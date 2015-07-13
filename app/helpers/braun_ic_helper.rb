module BraunIcHelper
  def adjust_braun_ic_reward(reward, inactive, activated_at)
    if inactive
      image = reward.not_awarded_image
    else
      image = reward.main_image
    end

    { 
      name: reward.name,
      title: reward.title,
      description: reward.short_description,
      image: image,
      cost: reward.cost,
      extra_fields: reward.extra_fields,
      inactive: inactive,
      activated_at: activated_at
    }
  end  
end