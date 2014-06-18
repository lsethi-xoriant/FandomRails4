
rule "DUP", 
  rewards: [{ "POINT" => 10 }] { 
    (user_interaction.counter == 1) 
  }

rule "OPTIONS", 
  reward: [{ "POINT" => 10 }] { 
    (user_interaction.counter == 1) 
  }

rule "DUP", 
  rewards: [{ "POINT" => 10}] { 
    first_time 
  }

