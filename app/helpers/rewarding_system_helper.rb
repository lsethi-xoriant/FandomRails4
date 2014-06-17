# Implements the "rule" function and an engine to run a set of rules stored in a buffer
module RewardingSystemHelper

  # Context used to evaluate the block of a rule
  class Context
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    attribute :user #, type: User
    attribute :interaction #, type: Interaction
    attribute :user_interaction #, type: UserInteraction
    attribute :user_rewards, type: Hash
  end

  # Creates a context and evaluate block to check if rewards should be awared.
  #
  # options - defines the rewards to assign and some constrains for the application of the rule:
  #     :rewards      - a list of reward names, or pairs of reward name plus a counter
  #     :interactions - a list of names of the interactions to which this rule applies
  #     :ctas         - a list of names of the ctas whose interactions should be considered
  #     :tags         - a list of names of the tags of the ctas whose interactions should be considered
  #     :interaction_types - a list of types of interactions that should be considered
  #
  # Examples: 
  #
  #   rule rewards: [["POINTS", 10]] { user_interaction.counter == 1 }
  #   # => assigns 10 points to all interactions that have been executed the first time
  #
  #   rule rewards: [["POINTS", 5]], tags: ["SUPERWIN"], interaction_types: ["PLAY"] { |context| context.user_interaction.counter == 1 }
  #   # => assigns 5 more points to the SUPERWIN interaction
  #
  #   rule rewards: ["LEVEL"] { |context| user.user_rewards["LEVEL"].counter == 1 && user.user_rewards["POINTS"].counter > 100 }
  #   rule rewards: ["LEVEL"] { |context| user.user_rewards["LEVEL"].counter == 2 && user.user_rewards["POINTS"].counter > 1000 }
  #   ...
  #   # => defines levels
  def rule *options, &block
    
  end
end
