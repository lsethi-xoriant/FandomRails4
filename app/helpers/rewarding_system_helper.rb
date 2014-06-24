module RewardingSystemHelper
  include EventHandlerHelper

  # The Abstract Syntax of a rule
  class Rule
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    ALLOWED_OPTIONS = [:interactions, :rewards, :unlocks, :repeatable, :draft, :validity_start, :validity_end]
    
    attribute :name, type: String
    attribute :options #, type: Hash
    attribute :condition #, type: Proc
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
      self.rewards.default = 0
      self.unlocks.default = 0
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
    attribute :user_reward_names #, type: Array # of String
    attribute :user_unlocked_names #, type: Array # of String
    
    # this list is populated by side-effects by evaluating the rules buffer 
    attribute :rules #, type: Array
    
    # these attributes are set by side-effect when evaluating each rule
    attribute :rule_rewards #, type: Array
    attribute :rule_unlocks #, type: Array
    
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
      self.rule_rewards = Set.new(rule.options[:rewards])
      self.rule_unlocks = Set.new(rule.options[:unlocks])

      if rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction)
        begin
          if rule.condition.nil? || rule.condition.call
            outcome.matching_rules << rule.name
            merge_rewards(outcome.reward_name_to_counter, rule_rewards)          
            outcome.unlocks += rule_unlocks          
          end
        rescue Exception => ex
          outcome.errors << "rule #{rule.name}: #{ex}\n#{ex.backtrace.join("\n")}" 
        end
      end
    end
    
    def rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction)
      repeatable = rule.options.fetch(:repeatable, false)
      return (
        !user_already_own_rewards?(rule_rewards, rule_unlocks) &&
        (repeatable || user_interaction.counter <= 1) &&
        current_datetime_is_valid?(rule.options) &&
        interaction_matches?(user_interaction, rules.options, just_rules_applying_to_interaction) 
      )
    end
    
    def user_already_own_rewards?(rule_rewards, rule_unlocks)
      rule_rewards.subset?(user_reward_names) and rule_unlocks.subset?(user_unlocked_names)
    end
    
    def current_datetime_is_valid?(options)
      now = DateTime.now
      return ( (!options.key?(:validity_start) || now >= options[:validity_start]) and
               (!options.key?(:validity_end) || now <= options[:validity_end]) )
    end

    def interaction_matches?(user_interaction, options, just_rules_applying_to_interaction)
      if options.key?(:interations)
        return (
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
    
    # A rule reward is either a simple String (i.e. just one of the mentioned reward) or an array matching reward names with a quantity
    def merge_rewards(rewards, rule_rewards)
      rule_rewards.each do |reward|
        if reward.is_a? String
          rewards[reward] = 1 
        else
          reward.each do |k, v|
            rewards[k] += v
          end
        end
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
        condition: proc(&block) })
      rules << rule 
    end
  end
    
  def new_context(user_interaction)
    user = user_interaction.user
    interaction = user_interaction.interaction
    user_rewards = get_user_rewards(user_interaction.user)
    Context.new(
      user: user,
      user_rewards: user_rewards,
      cta: interaction.calltoaction,
      correct_answer: get_correct_answer(user_interaction),
      counters: get_counters(user),
      user_reward_names: Set.new(user_rewards.keys),
      user_unlocked_names: Set.new(user_rewards.select { |k, v| v.unlocked }.keys),
      rules: []
    )
  end
  
  def get_user_rewards(user)
    result = UserReward.get_rewards_names_to_counters(user)
    rewards = Reward.get_all_reward_names
    rewards.each do |name|
      unless user_reward_names_to_counters.key?(name)
        result[name] = 0
      end
    end
    result
  end
  
  def get_correct_answer(user_interaction)
    user_interaction.is_answer_correct?
  end  

  # TODO: to be implemented
  def get_counters(user)
    { 
      'DAILY' => Counter.new,
      'TOTAL' => Counter.new
    }
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
      end
    end
    if !options.key? :rewards and !options.key? :unlocks
        errors << "rule #{rule.name}: rewards and unlocks are both missing"          
    end          
  end
  
  # Evaluates a rules_buffer in the context of an user interaction.
  # Returns an instance of the class Outcome
  def compute_outcome(user_interaction, rules_buffer = nil)
    context = prepare_rules_and_context(user_interaction, rules_buffer)    
    context.compute_outcome()
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
      Setting.find_by_key('rewarding.rules')
    end
  end
  
  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    outcome = compute_outcome(user_interaction, rules_buffer)
    if outcome.rewards.any? || outcome.unlocks.any?
      log_event("reward event: #{outcome.to_json}")
      user = user_interaction.user
      outcome.reward_name_to_counter.each do |reward_name, reward_counter|
        UserReward.assign_reward(user, reward_name, reward_counter)
      end          
      outcome.unlocks.each do |reward_name|
        UserReward.unlock_reward(user, reward_name)
      end          
    end
  end

  def predict_outcome(interaction, user)
    context = prepare_rules_and_context(user_interaction, rules_buffer)    
    context.predict_outcome()
  end

end


