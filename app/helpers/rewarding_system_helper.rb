module RewardingSystemHelper

  # The Abstract Syntax of a rule
  class Rule
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    ALLOWED_OPTIONS = [:interactions, :rewards, :unlocks, :repeatable, :draft, :validity_start, :validity_end, :condition]
    ALLOWED_INTERACTIONS = [:names, :tags, :ctas, :types]
    
    attribute :name, type: String
    attribute :options #, type: Hash
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
        reward_name_to_counter[k] = reward_name_to_counter[k].nil? ? v : reward_name_to_counter[k] + v
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
        self.reward_name_to_counter.default = 0
      end
    end

    def merge!(other)
      Outcome.merge_rewards(self.reward_name_to_counter, other.reward_name_to_counter)          
      self.matching_rules += other.matching_rules 
      self.unlocks += other.unlocks 
      self.errors += other.errors 
    end

    # This method sets the outcome with max reward_name_to_counter values among self and other outcome
    def set_max!(other)
      if other.nil?
        return
      else
        new_reward_counters = {}
        self.reward_name_to_counter.each do |key, value|
          new_reward_counters[key] = [value, other.reward_name_to_counter.fetch(key, 0)].max
        end
        other.reward_name_to_counter.each do |key, value|
          new_reward_counters[key] ||= value
        end
        self.reward_name_to_counter = new_reward_counters
      end
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
    
    attribute :rules_collector #, type: RulesCollector

    def first_time
      user_interaction.counter == 1
    end

    def get_interaction_rules(interaction)
      result = rules_collector.interaction_id_by_rules[interaction.id]
      if result.nil?
        if interaction.is_a? MockedInteraction
          return []
        end
        
        # refresh rules_collector
        rules_collector = get_rules_collector(interaction.call_to_action)
        result = rules_collector.interaction_id_by_rules[interaction.id]
        if result.nil?
          log_error("cannot find interaction in rules collector", { interaction: interaction.id })
          return []
        end
      end
      result
    end

    # Evaluates all rules in this context and return an Outcome object    
    def compute_outcome(user_interaction, just_rules_applying_to_interaction = false)
      outcome = Outcome.new()
      unless (user_interaction.mocked? && user_interaction.there_is_no_interaction?)
        interaction_rules = get_interaction_rules(user_interaction.interaction)
        interaction_rules.each do |rule|
          evaluate_rule(rule, outcome, user_interaction)
        end
      end
      unless just_rules_applying_to_interaction
        rules_collector.context_only_rules.each do |rule|
          evaluate_rule(rule, outcome, user_interaction)
        end
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
    def evaluate_rule(rule, outcome, user_interaction)
      if rule_should_be_evaluated(rule, user_interaction, outcome)
        begin
          if !rule.options.key?(:condition) || eval(rule.options[:condition])
            outcome.matching_rules << rule.name
            Outcome.merge_rewards(outcome.reward_name_to_counter, rule.normalized_rewards)          
            merge_user_rewards(self.user_rewards, rule.normalized_rewards)
            outcome.unlocks += rule.unlocks
            self.user_unlocked_names += rule.unlocks
            # TODO: self.uncountable_user_reward_names should be updated as well 
            outcome.info << ["rule evaluation", { rule_name: rule.name, value: true }]
          else 
            outcome.info << ["rule evaluation", { rule_name: rule.name, value: false }]
          end
        rescue Exception => ex
          outcome.errors << ["exception on rule",  { rule_name: rule.name, exception: ex.to_s }] 
        end
      end
    end
    
    def rule_should_be_evaluated(rule, user_interaction, outcome)
      repeatable = rule.options.fetch(:repeatable, false)
      
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
    
    # Similar to merge_rewards, but the value of the map is a MockedUserReward
    def merge_user_rewards(user_rewards, normalized_rule_rewards)
      normalized_rule_rewards.each do |k, v|
        user_rewards[k].counters.each do |period, old_value|
           user_rewards[k].counters[period] = old_value + v
        end
      end
    end

  end
  
  def new_context(user_interaction, rules_collector)
    st = Time.now.utc 
    user = user_interaction.user
    if user_interaction.mocked?
      cta = nil
    else
      cta = user_interaction.interaction.call_to_action
    end
    if user.mocked?
      Context.new(
        user: user,
        cta: cta,
        correct_answer: get_correct_answer(user_interaction),
        uncountable_user_reward_names: Set.new(),
        user_unlocked_names: Set.new(),
        user_rewards: fill_user_rewards({}),
        rules_collector: rules_collector
      )
    else
      user_reward_info = UserReward.get_rewards_info(user_interaction.user, get_current_periodicities)
      user_rewards, uncountable_user_reward_names, user_unlocked_names = get_user_reward_data(user_reward_info)
      Context.new(
        user: user,
        cta: cta,
        correct_answer: get_correct_answer(user_interaction),
        uncountable_user_reward_names: uncountable_user_reward_names,
        user_unlocked_names: user_unlocked_names,
        user_rewards: user_rewards,
        rules_collector: rules_collector
      )
    end
  end
  
  # Mocks a user reward, to be used in rules.
  class MockedUserReward
    # counters is an hash of periodicity to numbers
    def initialize(counters)
      @counters = counters
    end

    attr_accessor :counters
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
      end 
      if available
        user_unlocked_names << name
      end
      if !countable
        uncountable_user_reward_names << name
      end
    end
    fill_user_rewards(user_rewards)
    [user_rewards, uncountable_user_reward_names, user_unlocked_names]
  end

  # Fills the user_rewards argument with all rewards names, with counters set to 0
  def fill_user_rewards(user_rewards)
    get_all_reward_names().each do |name|
      if user_rewards.key?(name)
        counters = user_rewards[name].counters
      else
        counters = {}
        user_rewards[name] = MockedUserReward.new(counters) 
      end
      get_all_periodicity_kinds().each do |periodicity_kind|
        unless counters.key?(periodicity_kind)
          counters[periodicity_kind] = 0
        end
      end
      user_rewards[name].counters = counters 
    end
    user_rewards
  end

  def get_all_periodicity_kinds()
    $site.periodicity_kinds + [PERIOD_KIND_TOTAL]
  end
  
  def get_correct_answer(user_interaction)
    user_interaction.is_answer_correct?
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
    if Rails.env == 'development' || get_deploy_setting('rewarding.system/log_outcome', false)
      log_info("outcome messages", { info: outcome.info, errors: outcome.errors })
      # empty the lists of info/errors for performance
      outcome.info = []
      outcome.errors = []
    end
  end

  def prepare_rules_and_context(user_interaction, rules_collector = nil)
    if rules_collector.nil?
      rules_collector = get_rules_collector(user_interaction.interaction.call_to_action)
    end
    context = new_context(user_interaction, rules_collector)
    context        
  end
  
  def check_rules(buffer)
    init_check_rules_aux(RulesCollector.new, Rule::ALLOWED_OPTIONS, Rule::ALLOWED_INTERACTIONS)
    check_rules_aux(buffer)
  end
  
  def get_rules_collector(call_to_action)
    cache_short(get_rewarding_rules_collector_cache_key(call_to_action.id)) do 
      rules_buffer = Setting.find_by_key(REWARDING_RULE_SETTINGS_KEY).value
      rules_collector = RulesCollector.new
      # WARNING: instance_eval
      rules_collector.instance_eval(rules_buffer)
      rules_collector.set_interaction_id_by_rules(call_to_action.interactions, self)
      rules_collector
    end
  end
  
  def compute_and_save_outcome(user_interaction, rules_buffer = nil)
    start_time = Time.now.utc
    outcome = compute_outcome(user_interaction, rules_buffer)
    total_time = Time.now.utc - start_time

    if outcome.reward_name_to_counter.any? || outcome.unlocks.any?  
      log_synced("assigning reward to user", { 
        'time' => total_time, 
        'interaction' => user_interaction.mocked? ? nil : user_interaction.interaction.id, 
        'outcome_rewards' => outcome.reward_name_to_counter, 
        'outcome_unlocks' => outcome.unlocks.to_a })

      user = user_interaction.user
      outcome.reward_name_to_counter.each do |reward_name, reward_counter|
        assign_reward(user, reward_name, reward_counter, $site)
        clear_cache_reward_points(reward_name, user)
      end          
      outcome.unlocks.each do |reward_name|
        UserReward.unlock_reward(user, reward_name)
      end          
    end
    outcome
  end

  def clear_cache_reward_points(reward_name, user)
    expire_cache_key(get_reward_points_for_user_key(reward_name, user.id))
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

    def id
      -1
    end
  end
  MOCKED_USER = MockedUser.new

  class MockedCallToAction
    def id
      0
    end
    
    def interactions
      []
    end
  end
  
  class MockedInteraction
    attr_accessor :call_to_action
    def initialize()
      @call_to_action = MockedCallToAction.new
    end
    
    def id
      0
    end
  end
  
  # Simulate an user interaction where the correctness of an answer/interaction can be set in advance.
  # It is used to predict the outcome of an interaction.
  class MockedUserInteraction
    def initialize(interaction, user, counter, interaction_is_correct)
      @interaction = interaction
      @user = user
      @user_id = user.id
      @counter = counter
      @interaction_is_correct = interaction_is_correct
    end
    
    attr_accessor :counter, :user_id, :user, :interaction
    
    def is_answer_correct?
      @interaction_is_correct
    end
    
    def there_is_no_interaction?
      @interaction.nil?
    end
    
    def mocked?
      true
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
    log_debug("predict interaction outcome", { 
      'time' => total_time, 
      'interaction' => interaction.id, 
      'outcome_rewards' => outcome.reward_name_to_counter, 
      'outcome_unlocks' => outcome.unlocks.to_a })

    outcome
  end

  # Predicts the maximum outcome of a CTA.
  #   cta - the cta
  #   user - the user performing the interaction; if nil or anonymous, the context of the interaction will be reset (counters and rewards)
  def predict_max_cta_outcome(cta, user)
    if is_linking?(cta.id)

      graph, cycles = CtaForest.build_linked_cta_graph(cta.id)
      tree = graph[cta.id]
      total_outcome, interaction_outcomes, sorted_interactions = build_max_cta_outcome(cta, user)
      if cycles.empty?
        visited = {}
        total_outcome = compute_max_outcome(tree, user, get_ctas_for_max_outcome(), visited)
      end

      total_outcome.reward_name_to_counter.default = nil
      [total_outcome, interaction_outcomes, sorted_interactions]

    else
      build_max_cta_outcome(cta, user)
    end
  end

  def build_max_cta_outcome(cta, user)

    sorted_interactions = interactions_required_to_complete(cta)

    if sorted_interactions.count == 0
      [Outcome.new, [], []] 
    else
      if user.nil?
        user = MOCKED_USER
      end

      cache_key = "#{cta.id}_#{user.id}"
      cache_timestamp = get_user_interactions_max_updated_at_for_cta(user, cta)

      total_outcome, interaction_outcomes, sorted_interactions = cache_forever(get_outcome_values_cache_key(cache_key, cache_timestamp)) do

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
        log_debug("predict max cta outcome", { 
          'time' => total_time, 
          'cta' => cta.id, 
          'outcome_rewards' => total_outcome.reward_name_to_counter, 
          'outcome_unlocks' => total_outcome.unlocks.to_a })

        [total_outcome, interaction_outcomes, sorted_interactions]
      end
      [total_outcome, interaction_outcomes, sorted_interactions]
    end

  end

  def compute_max_outcome(tree, user, ctas, visited)
    total_outcome, interaction_outcomes, sorted_interactions = build_max_cta_outcome(ctas[tree.value], user)
    visited[tree.value] = total_outcome

    if tree.children.any?
      childrens_outcomes = []
      tree.children.each do |child|
        if visited[child.value].nil?
          visited[child.value] = compute_max_outcome(child, user, ctas, visited)          
        end
        childrens_outcomes << visited[child.value]
      end

      max_children_outcome = get_max_children_outcome!(childrens_outcomes)
      total_outcome = sum_total_outcome_with_children(total_outcome, max_children_outcome)
    end
    total_outcome
  end

  def get_max_children_outcome!(childrens_outcomes)
    result_outcome = childrens_outcomes.pop
    childrens_outcomes.each do |outcome|
      result_outcome.set_max!(outcome)
    end
    result_outcome
  end

  def sum_total_outcome_with_children(total_outcome, max_children_outcome)
    result = Outcome.new()
    result.reward_name_to_counter = sum_hashes_values(total_outcome.reward_name_to_counter, max_children_outcome.reward_name_to_counter)
    result
  end

  def get_ctas_for_max_outcome()
    cta_ids = CtaForest.get_neighbourhood_map().keys
    cache_timestamp = get_cta_max_updated_at(cta_ids)

    ctas = cache_forever(get_ctas_for_max_outcome_cache_key(cache_timestamp)) do
      ctas = {}
      CallToAction.where(:id => cta_ids).each do |cta|
        ctas[cta.id] = cta
      end
      ctas
    end
  end

end
