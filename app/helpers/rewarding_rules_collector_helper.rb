module RewardingRulesCollectorHelper
  
  ALL = "ALL INTERACTIONS"
    
  class RulesCollector
    attr_accessor :rules, :interaction_id_by_rules, :context_only_rules
    
    def initialize()
      @rules = []
      @interaction_id_by_rules = {}
      @context_only_rules = []
      # in memory cache used to avoid going to memcache during rules computation
      @cta_id_to_tags_cache = {} 
    end
    
    # This is the method called by the rules file, through instance_eval. It just stores all parameters (and the block)
    # into a data structure to process it later.
    #
    # name - the name of the rule, used for logging
    # options
    #     :rewards      - a list of rewards to assign if the rule matches; the list contains names, or 
    #                     hashes mapping names to counters (for example to award 10 points write { MAIN_REWARD_NAME => 10 })
    #     :unlock       - a list of reward names to unlock
    #     :condition    - the condition by which the rewards should be assigned or unlocked  
    def rule(name, options)
      rule = Rule.new({ 
        name: name,
        options: options,
        normalized_rewards: normalize_rewards(options),
        unlocks: Set.new(options.fetch(:unlocks, []))
        })
      rules << rule
      
      unless rule.options.key?(:interactions)
        @context_only_rules << rule
      end  
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
    
    # parent_object is the object calling this service; it is used to access logging and caching
    def set_interaction_id_by_rules(interactions, parent_object)
      interactions.each do |interaction|
        @rules.each do |rule|
          if interaction_matches?(interaction, rule.options, parent_object)
            (@interaction_id_by_rules[interaction.id] ||= []) << rule
          end
        end
      end
    end
  end

  def interaction_matches?(interaction, options, parent_object)
    options.key?(:interactions) && (
      ALL.equal?(options[:interactions]) || (
        interaction_is_included_in_options?(options, :names, interaction.name) &&
        interaction_is_included_in_options?(options, :ctas, interaction.call_to_action.name) &&
        interaction_type_is_included_in_options?(options, interaction) &&
        (!options[:interactions].key?(:tags) || 
          (get_cta_tags(interaction.call_to_action, parent_object) & (options[:interactions][:tags])).count > 0)
      )
    )
  end

  def get_cta_tags(cta, parent_object)
    if @cta_id_to_tags_cache.include?(cta.id) 
      @cta_id_to_tags_cache[cta.id] 
    else
      tags = parent_object.get_cta_tags_from_cache(cta)
      @cta_id_to_tags_cache[cta.id] = tags
      tags
    end
  end

  def interaction_is_included_in_options?(options, label, element)
    !options[:interactions].key?(label) || (!element.nil? && options[:interactions][label].include?(element)) 
  end

  # Checks if the interaction type matches with what has been specified in the options parameter.
  # It handles a kind of subtype relation between Quiz and Trivia or Versus 
  def interaction_type_is_included_in_options?(options, interaction)
    (
      interaction_is_included_in_options?(options, :types, interaction.resource_type) || 
      (interaction.resource_type == "Quiz" && interaction_is_included_in_options?(options, :types, interaction.resource.quiz_type.capitalize)) || 
      (interaction.resource_type == "Basic" && interaction_is_included_in_options?(options, :types, interaction.resource.basic_type.capitalize))
    )      
  end

end
