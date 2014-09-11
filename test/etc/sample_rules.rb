###################################################################################################
#
# Basics
#

rule "GIVE_SOME_TO_ALL", 
  interactions: ALL,
  rewards: [{ MAIN_REWARD_NAME => 10 }]
# => assigns 10 points to all interactions that have been executed the first time

###################################################################################################
#
# Match by type and tags
#

rule "QUIZ_RULE",
  interactions: { types: ["QUIZ"], ctas: ["SUPERWIN"] },
  rewards: [{ MAIN_REWARD_NAME => 5 }] { 
    correct_answer
  }
# => assigns 2 points to interaction of type quiz of CTA "superwin", if the answer is correct

rule "PLAY_RULE",
  interactions: { types: ["PLAY"], tags: ["NEW_PLAY"] },  
  rewards: [{ MAIN_REWARD_NAME => 5 }]
# => assigns 5 more points to interaction of type PLAY, for CTA with tag "NEW_PLAY"

#################################################################################################
#
# Badge etc.
#
 
rule "DEDICATED_PLAYER",
  rewards: ["DEDICATED_PLAYER"] { 
    user_rewards[MAIN_REWARD_NAME].counter > 1000
  } 
# => assigns a badge if the user has more than 1000 points

rule "LADDER", 
  interactions: { names: ["FULL_REGISTRATION"] },
  rewards: ["LADDER"]
# => the LADDER reward grant access to the site ladder; it is awarded if the user completes the "FULL_REGISTRATION" CTA

##################################################################################################
#
# Counters
#
# [implementation note] they are implemented as a cache on actual events; for performance reason they can't be recomputed from scratch
# so the counters are stored in a persistent DB.
# 

rule "DEDICATED_PLAYER_BADGE",
  rewards: ["DEDICATED_PLAYER_BADGE"] { 
    counters["DAILY"].correct_answer > 100 
  } 
# => assigns a badge if the total correct answers in a day are more than 100


rule "ADDICTED_PLAYER_BADGE", 
  rewards: ["ADDICTED_PLAYER_BADGE"] { 
    counters["TOTAL"].correct_answer > 1000 
  } 
# => assigns a badge if the total correct answers are more than 1000


##################################################################################################
#
# Levels
#

rule "LEVEL2",
  rewards: ["LEVEL"] { 
    user_rewards["LEVEL"].counter == 1 and user_rewards[MAIN_REWARD_NAME].counter > 99 
  }

rule "LEVEL3",
  rewards: ["LEVEL"] { 
    user_rewards["LEVEL"].counter == 2 and user_rewards[MAIN_REWARD_NAME].counter > 199 
  }


#################################################################################################
#
# Unlocking
#
# Instead (or in addition) of assigning a reward, unlock it. The API is the same as above

rule "UNLOCK_RULE",
  unlocks: ["SPECIAL_AVATAR"] { 
    user_rewards[MAIN_REWARD_NAME].counter > 10000
  } 


##################################################################################################
#
# Not supported: 
# - 1 access per day for X days. 
