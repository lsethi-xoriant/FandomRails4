User.create(email: "atolomio@shado.tv", first_name: "Alessandro", last_name: "Tolomio", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "sbartolucci@shado.tv", first_name: "Stefano", last_name: "Bartolucci", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "ddainese@shado.tv", first_name: "Diego", last_name: "Dainese", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "anonymous@shado.tv", first_name: "Anonymous", last_name: "Anonymous", 
						privacy: true, password: "shado00", password_confirmation: "shado00")
						
Setting.create(key: "rewarding.rules", value: <<-EOF
rule "PLAY_VIDEO",
  interactions: { types: ["Play"] },  
  rewards: [{ "POINT" => 5 }]

rule "QUIZ_ANSWER",
  interactions: { types: ["Quiz"] },
  rewards: [{ "POINT" => 10 }] 

rule "QUIZ_CORRECT",
  interactions: { types: ["Quiz"] },
  rewards: [{ "POINT" => 15 }] { 
    correct_answer
  }
EOF
)

Reward.create(name: "POINT", title: "Points", countable: true, numeric_display: true)