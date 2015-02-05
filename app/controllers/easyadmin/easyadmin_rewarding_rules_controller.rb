class Easyadmin::EasyadminRewardingRulesController < Easyadmin::EasyadminController
  include EasyadminHelper
  include RewardingSystemHelper

  layout "admin"

  def index
    rules = Setting.find_by_key(REWARDING_RULE_SETTINGS_KEY)
    @saved = true
    if !rules
      @rules = Setting.create(:key => REWARDING_RULE_SETTINGS_KEY, :value => "")
    end
    @rules_value = rules.value
  end
  
  def save
    errors = check_rules(params[:rules])
    if errors.any?
      flash[:error] = errors
      @saved = false
      @rules_value = params[:rules]
      render template: "/easyadmin/easyadmin_rewarding_rules/index"
    else
      rules = Setting.find_by_key(params[:key])
      rules.update_attribute(:value, params[:rules])
      @saved = true
      @rules_value = rules.value
      flash[:notice] = "Regole aggiornate correttamente"
      render template: "/easyadmin/easyadmin_rewarding_rules/index"
    end
  end

end