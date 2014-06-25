# General utilities on the models
module ModelHelper

  def get_all_model_names(model)
    cache_short do
      Set.new(model.select("name").map { |m| m.name })
    end
  end

  def get_all_interaction_names
    get_all_model_names(Interaction)
  end

  def get_all_reward_names
    get_all_model_names(Reward)
  end
  
end