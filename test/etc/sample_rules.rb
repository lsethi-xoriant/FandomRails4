###################################################################################################
#
# Basics
#
rule "GIVE_SOME_TO_ALL", 
  rewards: [{ "POINT" => 10 }] { 
    (user_interaction.counter == 1) 
  }
# => assigns 10 points to all interactions that have been executed the first time

rule "GIVE_SOME_MORE_TO_ALL", 
  rewards: [{ "POINT" => 10}] { 
    first_time 
  }
# => another way to write the same

###################################################################################################
#
# Match by type and tags
#

rule "QUIZ_RULE",
  rewards: [{ "POINT" => 5 }] { 
    first_time and 
    correct_answer and
    user_interaction.tyepe == "QUIZ" and 
    cta.name != "SUPERQUIZ" 
  }
# => assigns 2 more points to interaction of type quiz, except for CTA "SUPERQUIZ"

rule "SUPERWIN_RULE", 
  rewards: [{ "POINT" => 15 }] { 
    first_time and
    correct_answer and
    user_interaction.name == "SUPERWIN" 
  }
# => assigns 15 more points to the SUPERWIN interaction

rule "PLAY_RULE", 
  rewards: [{ "POINT" => 5 }] { 
    first_time and
    user_interaction.type == "PLAY" and 
    not(cta.tags.include("NEW_PLAY")) 
  }
# => assigns 5 more points to interaction of type PLAY, except for CTA with tag "NEW_PLAY"

rule "NEW_PLAY_RULE",
  rewards: [{ "POINT" => 100 }] { 
    first_time and 
    user_interaction.type == "PLAY" and 
    cta.tags.include?("NEW_PLAY")
  }
# => assigns 100 more points to interaction of type PLAY with tag "NEW_PLAY"

#################################################################################################
#
# Badge etc.
#
 
rule "DEDICATED_PLAYER",
  rewards: ["DEDICATED_PLAYER"] { 
    not(user_rewards.include?("DEDICATED_PLAYER")) and 
    user_rewards["POINT"].counter > 1000
  } 
# => assigns a badge if the user has more than 1000 points

rule "LADDER", 
  rewards: ["LADDER"] {
    not(user_has_it) and 
    user_interaction.name == "FULL_REGISTRATION"
  }
# => the LADDER reward grant access to the site ladder; it is awarded if the user completes the "FULL_REGISTRATION" CTA.
# "user_has_it" is another way to write: user_rewards.include? "LADDER" 


##################################################################################################
#
# Counters
#
# They are implemented as a cache on actual events; for performance reason they can't be recomputed from scratch
# so the counters are stored in a persistent DB.
# 
#

rule "DEDICATED_PLAYER_BADGE",
  rewards: ["DEDICATED_PLAYER_BADGE"] { 
    not(user_has_it) and 
    counters["DAILY"].correct_answer > 100 
  } 
# => assigns a badge if the total correct answers in a day are more than 100


rule "ADDICTED_PLAYER_BADGE", 
  rewards: ["ADDICTED_PLAYER_BADGE"] { 
    not(user_has_it) and 
    counters["TOTAL"].correct_answer > 1000 
  } 
# => assigns a badge if the total correct answers are more than 1000


##################################################################################################
#
# Levels
#

rule "LEVEL2",
  rewards: ["LEVEL"] { 
    user_rewards["LEVEL"].counter == 1 and user_rewards["POINT"].counter > 99 
  }

rule "LEVEL3",
  rewards: ["LEVEL"] { 
    user_rewards["LEVEL"].counter == 2 and user_rewards["POINT"].counter > 199 
  }


#################################################################################################
#
# Unlocking
#
# Instead (or in addition) of assigning a reward, unlock it. The API is the same as above

rule "UNLOCK_RULE",
  unlocks: ["SPECIAL_AVATAR"] { 
    not(user_unlocked_it) and 
    user_rewards["POINT"].counter > 10000
  } 



##################################################################################################
#
# Not supported: 
# - 1 access per day for X days. 
