module RewardingSystemHelper
  include EventHandlerHelper

  # The Abstract Syntax of a rule
  class Rule
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    ALLOWED_OPTIONS = [:interactions, :rewards, :unlocks, :repeatable, :draft, :validity_start, :validity_end]
    ALLOWED_INTERACTIONS = [:names, :tags, :ctas, :types]
    
    attribute :name, type: String
    attribute :options #, type: Hash
    attribute :condition #, type: Proc
    attribute :normalized_rewards #, type: Hash
    attribute :unlocks #, type: Hash
  end

  # The outcome of a matching process
  class Outcome
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    attribute :matching_rules #, type: Array
    attribute :reward_name_to_counter #, type: Hash[String, Int]
    attribute :unlocks #, type: Set
    attribute :errors #, type: Hash
    
    def initialize
      self.matching_rules = []
      self.reward_name_to_counter = {}
      self.unlocks = Set.new
      self.errors = []
    end
  end

  # Context used to parse and evaluate a buffer containing rules.
  # Most of the class attributes and methods of this class are called from within the parse rules themselves.
  class Context
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    attribute :user #, type: User
    attribute :interaction #, type: Interaction
    attribute :cta #, type: CallToAction
    attribute :correct_answer, type: Boolean
    attribute :counters #, type: Hash
    attribute :uncountable_user_reward_names #, type: Array # of String
    attribute :user_unlocked_names #, type: Array # of String
    
    # this list is populated by side-effects by evaluating the rules buffer 
    attribute :rules #, type: Array
    
    ALL = "ALL INTERACTIONS"
    
    def first_time
      user_interaction.counter == 1
    end

    # Evaluate all rules in this context and return an Outcome object    
    def compute_outcome(user_interaction)
      outcome = Outcome.new()
      rules.each do |rule|
        evaluate_rule(rule, outcome, user_interaction, false)
      end
      outcome
    end
    
    # Evaluate just the rules applying to an interaction, and return an Outcome object    
    def compute_outcome(user_interaction)
      outcome = Outcome.new()
      rules.each do |rule|
        evaluate_rule(rule, outcome, user_interaction, true)
      end
      outcome
    end
    
    def evaluate_rule(rule, outcome, user_interaction, just_rules_applying_to_interaction)
      if rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction)
        begin
          if rule.condition.nil? || rule.condition.call
            Rails.logger.info("rule #{rule.name} evaluate to true") 
            outcome.matching_rules << rule.name
            merge_rewards(outcome.reward_name_to_counter, rule.normalized_rewards)          
            outcome.unlocks += rule.unlocks
          else
            Rails.logger.info("rule #{rule.name} evaluate to false") 
          end
        rescue Exception => ex
          outcome.errors << "rule #{rule.name}: #{ex}\n#{ex.backtrace.join("\n")}" 
        end
      end
    end
    
    def rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction)
      repeatable = rule.options.fetch(:repeatable, false)
      
      if interaction_matches?(user_interaction, rule.options, just_rules_applying_to_interaction)
        Rails.logger.info("rule #{rule.name} not applied because interaction doesn't match") 
        return false
      end
      
      if user_already_own_rewards?(rule.normalized_rewards, rule.unlocks)
        Rails.logger.info("rule #{rule.name} not applied because user already own the rewards") 
        return false
      end

      if !repeatable && user_interaction.counter > 1
        Rails.logger.info("rule #{rule.name} not applied because user the user already done it") 
        return false
      end
      
      if !current_datetime_is_valid?(rule.options)
        Rails.logger.info("rule #{rule.name} because date/time is not valid") 
        return false
      end
      
      Rails.logger.info("rule #{rule.name} will be evaluated") 
      return true
    end
    
    def user_already_own_rewards?(normalized_rewards, unlocks)
      Set.new(normalized_rewards.keys).subset?(uncountable_user_reward_names) and unlocks.subset?(user_unlocked_names)
    end
    
    def current_datetime_is_valid?(options)
      now = DateTime.now
      return ( (!options.key?(:validity_start) || now >= options[:validity_start]) and
               (!options.key?(:validity_end) || now <= options[:validity_end]) )
    end

    def interaction_matches?(user_interaction, options, just_rules_applying_to_interaction)
      if options.key?(:interations)
        return options[:interactions].equals?(ALL) || (
          interaction_is_included_in_options?(options, :names, interaction.name) &&
          interaction_is_included_in_options?(options, :ctas, interaction.cta.name) &&
          interaction_is_included_in_options?(options, :types, interaction.type) &&
          options[:interactions].key?(:tags) && interaction.cta.tags.intersect?(options[:interactions][:tags])
        )
      else
        !just_rules_applying_to_interaction
      end
    end
    
    def interaction_is_included_in_options?(options, label, element)
      options[:interactions].key?(label) && options[:interactions][label].includes?(element) 
    end
    
    # Merges the rewards won with a single rule with those already won
    def merge_rewards(reward_name_to_counter, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        reward_name_to_counter[k] += v
      end
    end
    
    # This is the method called by the rules file, through an instance_eval. It just stores all parameters (and the block)
    # into a data structure to process it later.
    #
    # name - the name of the rule, used for logging
    # options
    #     :rewards      - a list of rewards to assign if the rule matches; the list contains names, or 
    #                     hashes mapping names to counters (for example to award 10 points write { "POINT" => 10 })
    #     :unlock       - a list of reward names to unlock
    #
    # The block defines the condition by which the rewards should be assigned or unlocked  
    def rule(name, options, &block)
      rule = Rule.new({ 
        name: name,
        options: options,
        condition: block.nil? ? nil : proc(&block), 
        normalized_rewards: normalize_rewards(options),
        unlocks: Set.new(options.fetch(:unlocks, []))
        })
      rules << rule 
    end

    # Convert the "rewards" clause, that is an Array of Hash or String, into an Hash 
    def normalize_rewards(options)
      result = {}
      result.default = 0    
      options.fetch(:rewards, []).each do |r|
        if r.is_a? String
          result[r] = 1 
        else
          r.each do |k, v|
            result[k] += v
          end
        end
      end
      result
    end

  end
  
  def new_context(user_interaction)
    user = user_interaction.user
    interaction = user_interaction.interaction
    user_reward_info = UserReward.get_rewards_info(user_interaction.user)
    user_rewards, uncountable_user_reward_names, user_unlocked_names = get_user_reward_data(user_reward_info)
    Context.new(
      user: user,
      user_rewards: user_rewards,
      cta: interaction.call_to_action,
      correct_answer: get_correct_answer(user_interaction),
      counters: get_counters(user),
      uncountable_user_reward_names: uncountable_user_reward_names,
      user_unlocked_names: user_unlocked_names,
      rules: []
    )
  end
  
  def get_user_reward_data(user_reward_info)
    user_rewards = {}
    user_unlocked_names = Set.new()
    uncountable_user_reward_names = Set.new()
    user_reward_info.each do |tuple|
      name, available, counter = tuple
      user_rewards[name] = counter
      if available
        user_unlocked_names << name
      end
      uncountable_user_reward_names << name 
    end
    rewards = Reward.get_names_and_countable_pairs
    rewards.each do |pair|
      name, countable = pair
      unless user_rewards.key?(name)
        user_rewards[name] = 0
      end
      if countable
        uncountable_user_reward_names.delete(name)
      end
    end
    [user_rewards, uncountable_user_reward_names, user_unlocked_names]
  end
  
  def get_correct_answer(user_interaction)
    user_interaction.is_answer_correct?
  end  

  def get_counters(user)
    UserCounter.get_by_user(user)
  end

  # Returns a list of strings describing errors in rules, or the empty list if there are no errors
  def check_rules(rules_buffer)
    context = Context.new(rules: [])
    begin
      context.instance_eval(rules_buffer)
    rescue Exception => e
      return ["caught an exception while parsing rules: #{e}"]
    else
      errors = []
      seen_rules = Set.new
      context.rules.each do |rule|
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
      unless Rule::ALLOWED_OPTIONS.include?(k)
        errors << "rule #{rule.name}: unrecognized option: #{k}"          
      end
      if k == :validity_start or k == :validity_end
        begin 
          options[k] = Date.parse(v)
        rescue
          errors << "rule #{rule.name}: date/time parse error on #{k}"
        end
      elsif k == :interactions
        check_rule_interactions_clause(rule, errors)
      elsif k == :rewards
        #check_names(get_reward_names(v), Reward.get_all_names)
      end
    end
    if !options.key? :rewards and !options.key? :unlocks
        errors << "rule #{rule.name}: rewards and unlocks are both missing"          
    end          
  end

  def check_rule_interactions_clause(rule, errors)
    
  end


  
  # Evaluates a rules_buffer in the context of an user interaction.
  # Returns an instance of the class Outcome
  def compute_outcome(user_interaction, rules_buffer = nil)
    context = prepare_rules_and_context(user_interaction, rules_buffer)    
    context.compute_outcome(user_interaction)
  end

  def prepare_rules_and_context(user_interaction, rules_buffer = nil)
    if rules_buffer.nil?
      rules_buffer = get_rules_buffer()
    end
    context = new_context(user_interaction)
    context.instance_eval(rules_buffer)
    context        
  end
  
  def get_rules_buffer()
    # TODO: cache should be invalidated on save of settings
    cache_short('rewarding_rules') do 
      Setting.find_by_key('rewarding.rules').value
    end
  end
  
  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    outcome = compute_outcome(user_interaction, rules_buffer)
    if outcome.reward_name_to_counter.any? || outcome.unlocks.any?
      log_event("reward event: #{outcome.to_json}")
      user = user_interaction.user
      outcome.reward_name_to_counter.each do |reward_name, reward_counter|
        UserReward.assign_reward(user, reward_name, reward_counter)
      end          
      outcome.unlocks.each do |reward_name|
        UserReward.unlock_reward(user, reward_name)
      end          
    end
    outcome
  end

  def predict_outcome(interaction, user)
    context = prepare_rules_and_context(user_interaction, rules_buffer)    
    context.predict_outcome(user_interaction)
  end

end


