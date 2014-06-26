module RewardingSystemHelper
  include EventHandlerHelper
  include ModelHelper
  include RewardingRuleCheckerHelper

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
      self.matching_rules = Set.new
      self.reward_name_to_counter = {}
      self.reward_name_to_counter.default = 0
      self.unlocks = Set.new
      self.errors = []
    end
    
    def merge!(other)
      merge_rewards(self.reward_name_to_counter, other.reward_name_to_counter)          
      self.matching_rules += other.matching_rules 
      self.unlocks += other.unlocks 
      self.errors += other.errors 
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
    attribute :user_rewards #, type: Hash
    
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
    def compute_outcome_just_for_interaction(user_interaction)
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
            merge_user_rewards(self.user_rewards, rule.normalized_rewards)
            outcome.unlocks += rule.unlocks
            self.user_unlocked_names += rule.unlocks
            # TODO: self.uncountable_user_reward_names should be updated as well 
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
      
      if !interaction_matches?(user_interaction, rule.options, just_rules_applying_to_interaction)
        Rails.logger.info("rule #{rule.name} not applied because interaction doesn't match") 
        return false
      end
      
      if user_already_own_rewards?(rule.normalized_rewards, rule.unlocks)
        Rails.logger.info("rule #{rule.name} not applied because user already own the rewards") 
        return false
      end

      if rule.options.key?(:interactions) && !repeatable && user_interaction.counter > 1
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
      interaction = user_interaction.interaction
      if options.key?(:interactions)
        return ALL.equal?(options[:interactions]) || (
          interaction_is_included_in_options?(options, :names, interaction.name) &&
          interaction_is_included_in_options?(options, :ctas, interaction.call_to_action.name) &&
          interaction_is_included_in_options?(options, :types, interaction.resource_type) &&
          (!options[:interactions].key?(:tags) || interaction.cta.tags.intersect?(options[:interactions][:tags]))
        )
      else
        !just_rules_applying_to_interaction
      end
    end
    
    def interaction_is_included_in_options?(options, label, element)
      !options[:interactions].key?(label) || options[:interactions][label].include?(element) 
    end
    
    # Merges the rewards won with a single rule with those already won.
    def merge_rewards(reward_name_to_counter, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        reward_name_to_counter[k] += v
      end
    end

    # Similar to merge_rewards, but the value of the map is a MockedUserReward
    def merge_user_rewards(user_rewards, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        user_rewards[k].counter += v
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
      user_rewards: user_rewards,
      rules: []
    )
  end
  
  # Mocks a user reward, to be used in rules.
  class MockedUserReward
    def initialize(counter)
      @counter = counter
    end
    
    def counter
      @counter
    end
    
    def counter=(num)
      @counter = num
    end
  end
  
  def get_user_reward_data(user_reward_info)
    user_rewards = {}
    user_unlocked_names = Set.new()
    uncountable_user_reward_names = Set.new()
    user_reward_info.each do |info|
      name = info.reward.name
      available = info.available
      countable = info.reward.countable
      counter = info.counter
      user_rewards[name] = MockedUserReward.new(counter)
      if !countable
        if available
          user_unlocked_names << name
        end
        uncountable_user_reward_names << name
      end 
    end
    get_all_reward_names().each do |name|
      unless user_rewards.key?(name)
        user_rewards[name] = MockedUserReward.new(0)
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
  
  def check_rules(buffer)
    init_check_rules_aux(Context.new(rules: []), Rule::ALLOWED_OPTIONS, Rule::ALLOWED_INTERACTIONS)
    check_rules_aux(result)
  end
  
  def get_rules_buffer()
    # TODO: cache should be invalidated on save
#    cache_short('rewarding_rules') do 
    Setting.find_by_key(REWARDING_RULE_SETTINGS_KEY).value
#   end
  end
  
  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    outcome = compute_outcome(user_interaction, rules_buffer)
    if outcome.reward_name_to_counter.any? || outcome.unlocks.any?
      log_event("reward event", "#{outcome.to_json}")
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


  def get_mocked_user_interaction(interaction, user, interaction_is_correct)
    if current_user.nil?
      MockedUserInteraction.new(interaction, user, 1, interaction_is_correct)
    else
      user_interaction = find_by_user_id_and_interaction_id(user_id, interaction_id)
      MockedUserInteraction.new(interaction, user, user_interaction.counter, interaction_is_correct)  
    end
  end

  # Simulate an user interaction where the correctness of an answer/interaction can be set in advance.
  # It is used to predict the outcome of an interaction.
  class MockedUserInteraction
    def initialize(interaction, user, counter, interaction_is_correct)
      @interaction = interaction
      @user = user
      @counter = counter
      @interaction_is_correct = interaction_is_correct
    end
    
    def counter
      @counter
    end
    
    def interaction
      @interaction
    end
    
    def user
      @user
    end
    
    def is_answer_correct?
      @interaction_is_correct
    end
  end

  def predict_outcome(interaction, user, interaction_is_correct)
    user_interaction = get_mocked_user_interaction(interaction, user, interaction_is_correct)
    context = prepare_rules_and_context(user_interaction, nil)    
    context.compute_outcome_just_for_interaction(user_interaction)
  end

  def predict_max_cta_outcome(cta)
    if cta.interactions.count == 0
      Outcome.new
    else
      first_interaction = cta.interactions[0]
      other_interactions = cta.interactions[1 .. -1]
  
      user_interaction = get_mocked_user_interaction(first_interaction, user, true)
      context = prepare_rules_and_context(user_interaction, nil)    
      outcome = context.compute_outcome_just_for_interaction(user_interaction)
  
      cta.other_interactions.each do |interaction|
        new_outcome = context.compute_outcome_just_for_interaction(user_interaction)
        outcome.merge!(new_outcome)
      end
      
      outcome
    end
  end

end
