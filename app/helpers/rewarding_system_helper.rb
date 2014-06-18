require "active_attr"
require "set"
require_relative "event_handler_helper"

module RewardingSystemHelper
  include EventHandlerHelper
  include UserRewardHelper

  # The Abstract Syntax of a rule
  class Rule
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    ALLOWED_OPTIONS = [:rewards, :unlocks]
    
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
    attribute :rewards #, type: Hash
    attribute :unlocks #, type: Hash
    attribute :errors #, type: Hash
    
    def initialize
      self.matching_rules = []
      self.rewards = {}
      self.unlocks = {}
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
    attribute :user_interaction #, type: UserInteraction
    attribute :user_rewards #, type: Hash
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
    
    def user_has_it
      rule_rewards.subset?(user_reward_names)
    end

    def user_unlocked_it
      rule_unlocks.subset?(user_unlocked_names)
    end

    def first_time
      user_interaction.counter == 1
    end

    # Evaluate all rules in this context and return an Outcome object    
    def compute_outcome()
      outcome = Outcome.new()
      rules.each do |rule|
        evaluate_rule(rule, outcome)
      end
      outcome
    end
    
    def evaluate_rule(rule, outcome)
      self.rule_rewards = Set.new(rule.options[:rewards])
      self.rule_unlocks = Set.new(rule.options[:unlocks])
      begin
        if rule.condition.call
          outcome.matching_rules << rule.name
          merge_rewards(outcome.rewards, rule_rewards)          
          merge_rewards(outcome.unlocks, rule_unlocks)          
        end
      rescue Exception => ex
        outcome.errors << "rule #{rule.name}: #{ex}\n#{ex.backtrace.join("\n")}" 
      end
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
      user_interaction: user_interaction,
      interaction: interaction,
      user: user,
      user_rewards: user_rewards,
      # TODO: check this relation
      cta: user_interaction.interaction.cta,
      correct_answer: get_correct_answer(user_interaction),
      counters: get_counters(user),
      user_reward_names: Set.new(user_rewards.keys),
      user_unlocked_names: Set.new(user_rewards.select { |k, v| v.unlocked }.keys),
      rules: []
    )
  end
  
  ##############################################################################
  #
  # TODO: complete the following methods
  
  # TODO: to be implemented
  # this must be populated for all rewards (putting a counter of 0 if the user has yet to win it)
  def get_user_rewards(user)
    { 
      'POINT' => Counter.new,
      'LEVEL' => Counter.new
    }
  end
  
  # TODO: to be implemented
  def get_correct_answer(user_interaction)
    false
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
    end
    if options.count == (options.keys - Rule::ALLOWED_OPTIONS).count
        errors << "rule #{rule.name}: rewards and unlocks are both missing"          
    end          
  end
  
  # Evaluates a rules_buffer in the context of an user interaction.
  # Returns an instance of the class Outcome
  def compute_outcome(user_interaction, rules_buffer = nil)
    if rules_buffer.nil?
      rules_buffer = get_rules_buffer(user_interaction)
    end
    context = new_context(user_interaction)
    context.instance_eval(rules_buffer)
    context.compute_outcome
  end

  # TODO: to be implemented
  def get_rules_buffer(user_interaction)
    
  end

  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    outcome = compute_outcome(user_interaction, rules_buffer)
    if outcome.rewards.any? || outcome.unlocks.any?
      log_event("reward event: #{outcome.to_json}")
      user = user_interaction.user
      outcome.rewards.each do |reward|
        assign_reward(user, reward.name, reward.counter)
      end          
      outcome.unlocks.each do |reward|
        unlock_reward(user, reward.name)
      end          
    end
  end

end


