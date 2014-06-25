module RewardingRuleCheckerHelper
  include ModelHelper

  def init(context, allowed_options, allowed_interactions)
    @context = context
    @allowed_options = allowed_options
    @allowed_interactions = allowed_interactions
    @all_reward_names = get_all_reward_names()
    @all_interaction_names = get_all_interaction_names()
  end
  #@all_tag_names = get_all_tag_names()
  #@all_cta_names = get_all_cta_names()

  # Returns a list of strings describing errors in rules, or the empty list if there are no errors
  def check_rules(rules_buffer)
    begin
      @context.instance_eval(rules_buffer)
    rescue Exception => e
      return ["caught an exception while parsing rules: #{e}"]
    else
      errors = []
      seen_rules = Set.new
      @context.rules.each do |rule|
        check_rule(rule, seen_rules, errors)
      end
      errors
    end
  end
  
  def check_rule(rule, seen_rules, errors)
    check_rule_duplicate(rule, seen_rules, errors)
    check_rule_options(rule, errors)
  end
  
  def check_rule_duplicate(rule, seen_rules, errors)
    if seen_rules.include?(rule.name)
      errors << "rule #{rule.name}: duplicated"          
    else
      seen_rules << rule.name
    end
  end
  
  def check_rule_options(rule, errors)
    options = rule.options
    options.each do |k, v|
      unless @allowed_options.include?(k)
        errors << "rule #{rule.name}: unrecognized option: #{k}"          
      end
      if k == :validity_start or k == :validity_end
        begin 
          options[k] = Date.parse(v)
        rescue
          errors << "rule #{rule.name}: date/time parse error on #{k}"
        end
      elsif k == :interactions
        check_rule_interactions_clause(v, rule, errors)
      end
    end
    check_names(rule.normalized_rewards.keys, @all_reward_names, rule, errors)
    check_names(rule.unlocks, @all_reward_names, rule, errors)
    if !options.key? :rewards and !options.key? :unlocks
        errors << "rule #{rule.name}: rewards and unlocks are both missing"          
    end          
  end

  def check_names(names, all_names, rule, errors)
    debugger
    names.each do |name|
      unless all_names.include?(name)
        errors << "rule #{rule.name}: undefined name #{name}"          
      end
    end
  end  

  def check_rule_interactions_clause(interactions, rule, errors)
    if interactions.is_a? Hash
      interactions.each do |k, v|
        unless @allowed_interactions.include?(k)
          errors << "rule #{rule.name}: unrecognized interactions' clause: #{k}"          
        end
      end    
      check_names(interactions.fetch(:names, []), @all_interaction_names, rule, errors)
      check_names(interactions.fetch(:types, []), INTERACTION_TYPES, rule, errors)
      #check_names(interactions.fetch(:ctas, []), CallToAction.get_all_names, rule, errors)
      #check_names(interactions.fetch(:tags, []), Tag.get_all_names, rule, errors)
    end
  end
end


