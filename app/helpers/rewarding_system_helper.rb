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
    attribute :errors #, type: Array
    attribute :info #, type: Array

    # Merges the rewards won with a single rule with those already won.
    def self.merge_rewards(reward_name_to_counter, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        reward_name_to_counter[k] += v
      end
    end

    def initialize(params = nil)
      if params.nil?
        self.matching_rules = Set.new
        self.reward_name_to_counter = {}
        self.reward_name_to_counter.default = 0
        self.unlocks = Set.new
        self.errors = []
        self.info = []
      else
        super(params)
        self.matching_rules = Set.new(self.matching_rules)
        self.unlocks = Set.new(self.unlocks)
      end
    end

    def merge!(other)
      Outcome.merge_rewards(self.reward_name_to_counter, other.reward_name_to_counter)          
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

    # Evaluates all rules in this context and return an Outcome object    
    def compute_outcome(user_interaction, just_rules_applying_to_interaction = false)
      outcome = Outcome.new()
      rules.each do |rule|
        evaluate_rule(rule, outcome, user_interaction, just_rules_applying_to_interaction)
      end
      outcome
    end
    
    # Evaluates just the rules applying to an interaction, and return an Outcome object    
    def compute_outcome_just_for_interaction(user_interaction)
      compute_outcome(user_interaction, true)
    end
    
    # Evaluates a single rule, updating both the current Context and the outcome object passed as parameter.
    #   rule - the rule to be evaluated
    #   outcome - the object used to collect the rewards assigned/unlocked
    #   user_interaction - the interaction made by the user
    #   just_rules_applying_to_interaction - if true, the rule is evaluated only if the rule is 
    def evaluate_rule(rule, outcome, user_interaction, just_rules_applying_to_interaction)
      if rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction, outcome)
        begin
          if rule.condition.nil? || rule.condition.call
            outcome.info << ["rule evaluation", { rule_name: rule.name, value: true }] 
            outcome.matching_rules << rule.name
            Outcome.merge_rewards(outcome.reward_name_to_counter, rule.normalized_rewards)          
            merge_user_rewards(self.user_rewards, rule.normalized_rewards)
            outcome.unlocks += rule.unlocks
            self.user_unlocked_names += rule.unlocks
            # TODO: self.uncountable_user_reward_names should be updated as well 
          else
            outcome.info << ["rule evaluation", { rule_name: rule.name, value: false }] 
          end
        rescue Exception => ex
          outcome.errors << ["exception on rule",  { rule_name: rule.name, exception: ex.to_s }] 
        end
      end
    end
    
    def rule_should_be_evaluated(rule, user_interaction, just_rules_applying_to_interaction, outcome)
      repeatable = rule.options.fetch(:repeatable, false)
      
      if !interaction_matches?(user_interaction, rule.options, just_rules_applying_to_interaction)
        outcome.info << ["rule #{rule.name} not applied because interaction doesn't match", {}] 
        return false
      end
      
      if user_already_own_rewards?(rule.normalized_rewards, rule.unlocks)
        outcome.info << ["rule #{rule.name} not applied because user already own the rewards", {}] 
        return false
      end

      if rule.options.key?(:interactions) && !repeatable && user_interaction.counter > 1
        outcome.info << ["rule #{rule.name} not applied because user the user already done it", {}] 
        return false
      end
      
      if !current_datetime_is_valid?(rule.options)
        outcome.info << ["rule #{rule.name} because date/time is not valid", {}] 
        return false
      end
      
      outcome.info << ["rule #{rule.name} will be evaluated", {}] 
      return true
    end
    
    def user_already_own_rewards?(normalized_rewards, unlocks)
      Set.new(normalized_rewards.keys).subset?(uncountable_user_reward_names) and unlocks.subset?(user_unlocked_names)
    end
    
    def current_datetime_is_valid?(options)
      now = nil # the "time" system call is only made if either validity option has been specified
      if options.key?(:validity_start)
        now = Time.now.utc
        validity_start = Time.parse(options[:validity_start]).utc
        if now < validity_start
          return false
        end 
      end
      
      if options.key?(:validity_end)
        now = now.nil? ? Time.now.utc : now
        validity_end = Time.parse(options[:validity_end]).utc
        if now > validity_end
          return false
        end 
      end
      
      return true
    end

    def interaction_matches?(user_interaction, options, just_rules_applying_to_interaction)
      interaction = user_interaction.interaction
      if options.key?(:interactions)
        return ALL.equal?(options[:interactions]) || (
          interaction_is_included_in_options?(options, :names, interaction.name) &&
          interaction_is_included_in_options?(options, :ctas, interaction.call_to_action.name) &&
          interaction_type_is_included_in_options?(options, interaction) &&
          (!options[:interactions].key?(:tags) || get_cta_tags_from_cache(interaction.cta).intersect?(options[:interactions][:tags]))
        )
      else
        !just_rules_applying_to_interaction
      end
    end
    
    def interaction_is_included_in_options?(options, label, element)
      !options[:interactions].key?(label) || options[:interactions][label].include?(element) 
    end

    # Checks if the interaction type matches with what has been specified in the options parameter.
    # It handles a kind of subtype relation between Quiz and Trivia or Versus 
    def interaction_type_is_included_in_options?(options, interaction)
      (interaction_is_included_in_options?(options, :types, interaction.resource_type) || 
       (interaction.resource_type == 'Quiz' &&
        interaction_is_included_in_options?(options, :types, interaction.resource.quiz_type.capitalize))
      )      
    end
    
    # Similar to merge_rewards, but the value of the map is a MockedUserReward
    def merge_user_rewards(user_rewards, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        user_rewards[k].counters.each do |period, old_value|
           user_rewards[k].counters[period] = old_value + v
        end
      end
    end
    
    # This is the method called by the rules file, through an instance_eval. It just stores all parameters (and the block)
    # into a data structure to process it later.
    #
    # name - the name of the rule, used for logging
    # options
    #     :rewards      - a list of rewards to assign if the rule matches; the list contains names, or 
    #                     hashes mapping names to counters (for example to award 10 points write { MAIN_REWARD_NAME => 10 })
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
    if user.mocked?
      Context.new(
        user: user,
        user_rewards: {},
        cta: interaction.call_to_action,
        correct_answer: get_correct_answer(user_interaction),
        counters: {},
        uncountable_user_reward_names: Set.new(),
        user_unlocked_names: Set.new(),
        user_rewards: fill_user_rewards({}),
        rules: []
      )
    else
      user_reward_info = UserReward.get_rewards_info(user_interaction.user, get_current_periodicities)
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
  end
  
  # Mocks a user reward, to be used in rules.
  class MockedUserReward
    # counters is an hash of periodicity to numbers
    def initialize(counters)
      @counters = counters
    end
    
    def counters
      @counters
    end
  end
  
  # Extracts interesting data from the UserReward model. 
  #   user_reward_info - the result of a complex query joining UserReward with Reward and Period.
  def get_user_reward_data(user_reward_info)
    user_rewards = {}
    user_unlocked_names = Set.new()
    uncountable_user_reward_names = Set.new()
    user_reward_info.each do |info|
      name = info.reward.name
      available = info.available
      countable = info.reward.countable
      counter = info.counter
      period_kind = info.period.nil? ? PERIOD_KIND_TOTAL : info.period.kind
      if user_rewards.key?(name)
        user_rewards[name].counters[period_kind.downcase] = counter
      else
        user_rewards[name] = MockedUserReward.new({ period_kind.downcase => counter })
        if !countable
          if available
            user_unlocked_names << name
          end
          uncountable_user_reward_names << name
        end
      end 
    end
    fill_user_rewards(user_rewards)
    [user_rewards, uncountable_user_reward_names, user_unlocked_names]
  end

  # Fills the user_rewards argument with all rewards names, with counters set to 0
  def fill_user_rewards(user_rewards)
    get_all_reward_names().each do |name|
      unless user_rewards.key?(name)
        user_rewards[name] = MockedUserReward.new({ PERIOD_KIND_TOTAL => 0 })
      end
    end
    user_rewards
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
    outcome = context.compute_outcome(user_interaction)
    log_outcome(outcome)
    outcome
  end
  
  def log_outcome(outcome)
    outcome.info.each do |params|
      log_info(*params)
    end
    outcome.errors.each do |params|
      log_error(*params)
    end
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
    check_rules_aux(buffer)
  end
  
  def get_rules_buffer()
    cache_short('rewarding_rules') do 
      Setting.find_by_key(REWARDING_RULE_SETTINGS_KEY).value
    end
  end
  
  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    start_time = Time.now.utc
    outcome = compute_outcome(user_interaction, rules_buffer)
    total_time = Time.now.utc - start_time

    log_outcome(outcome)
    if outcome.reward_name_to_counter.any? || outcome.unlocks.any?
  
      log_synced("assigning reward to user", { 
        'time' => total_time, 
        'cta' => user_interaction.interaction.call_to_action.name, 
        'interaction' => user_interaction.interaction.id, 
        'user' => user_interaction.user.username, 
        'outcome_rewards' => outcome.reward_name_to_counter, 
        'outcome_unlocks' => outcome.unlocks.to_a })
      
      log_info("reward event", :outcome => outcome)
      user = user_interaction.user
      outcome.reward_name_to_counter.each do |reward_name, reward_counter|
        assign_reward(user, reward_name, reward_counter, request.site)
      end          
      outcome.unlocks.each do |reward_name|
        UserReward.unlock_reward(user, reward_name)
      end          
    end
    outcome
  end

  def get_mocked_user_interaction(interaction, user, interaction_is_correct)
    if user.nil? or user.id.nil? or user.id == anonymous_user.id
      user = MOCKED_USER
      MockedUserInteraction.new(interaction, user, 1, interaction_is_correct)
    else
      user_interaction = UserInteraction.find_by_user_id_and_interaction_id(user.id, interaction.id)
      MockedUserInteraction.new(interaction, user, (user_interaction.nil? ? 1 : (user_interaction.counter + 1)), interaction_is_correct)  
    end
  end

  # Simulate an user with no rewards or interactions done.
  # It is used to predict the outcome of an interaction.
  class MockedUser
    def mocked?
      true
    end
    
    def username
      "$MockedUser"
    end
  end
  MOCKED_USER = MockedUser.new

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

  # Predicts the outcome of an interaction. It does not save the outcome in the DB.
  #   interaction - the interaction to be predicted
  #   user - the user performing the interaction; if nil or anonymous, the context of the interaction will be reset (counters and rewards)
  #   interaction_is_correct - specifies if the interaction should be treated as "correct" (i.e. givin more points), for example a correct trivia answer.
  def predict_outcome(interaction, user, interaction_is_correct)
    start_time = Time.now.utc
    
    user_interaction = get_mocked_user_interaction(interaction, user, interaction_is_correct)
    context = prepare_rules_and_context(user_interaction, nil)
    outcome = context.compute_outcome_just_for_interaction(user_interaction)

    total_time = Time.now.utc - start_time
    
    log_outcome(outcome)
    log_info("predict interaction outcome", { 
      'time' => total_time, 
      'cta' => interaction.call_to_action.name,
      'interaction' => interaction.id, 
      'user' => user_interaction.user.username, 
      'outcome_rewards' => outcome.reward_name_to_counter, 
      'outcome_unlocks' => outcome.unlocks.to_a })

    outcome
  end

  # Predicts the maximun outcome of a CTA.
  #   cta - the cta
  #   user - the user performing the interaction; if nil or anonymous, the context of the interaction will be reset (counters and rewards)
  def predict_max_cta_outcome(cta, user)
    sorted_interactions = interactions_required_to_complete(cta)

    if sorted_interactions.count == 0
      [Outcome.new, [], []] 
    else
      start_time = Time.now.utc
      
      interaction_outcomes = []
      
      total_outcome = Outcome.new

      if sorted_interactions.any?

        first_interaction = sorted_interactions[0]
        other_interactions = sorted_interactions[1 .. -1]
    
        user_interaction = get_mocked_user_interaction(first_interaction, user, true)
        context = prepare_rules_and_context(user_interaction, nil)  
        first_outcome = context.compute_outcome_just_for_interaction(user_interaction)

        interaction_outcomes << first_outcome
        total_outcome.merge!(first_outcome)
    
        other_interactions.each do |interaction|
          user_interaction = get_mocked_user_interaction(interaction, user, true)
          new_outcome = context.compute_outcome_just_for_interaction(user_interaction)
          interaction_outcomes << new_outcome
          total_outcome.merge!(new_outcome)
        end

      end
      
      log_outcome(total_outcome)

      total_time = Time.now.utc - start_time
      log_info("predict max cta outcome", { 
        'time' => total_time, 
        'cta' => cta.name, 
        'user' => user_interaction.user.username, 
        'outcome_rewards' => total_outcome.reward_name_to_counter, 
        'outcome_unlocks' => total_outcome.unlocks.to_a })
               
      [total_outcome, interaction_outcomes, sorted_interactions]
    end
  end

end
