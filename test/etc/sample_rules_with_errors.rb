
rule "DUP", 
  rewards: [{ MAIN_REWARD_NAME => 10 }] { 
    (user_interaction.counter == 1) 
  }

rule "OPTIONS", 
  reward: [{ MAIN_REWARD_NAME => 10 }] { 
    (user_interaction.counter == 1) 
  }

rule "DUP", 
  rewards: [{ MAIN_REWARD_NAME => 10}] { 
    first_time 
  }

