User.create(email: "atolomio@shado.tv", first_name: "Martino", last_name: "Russo", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "sbartolucci@shado.tv", first_name: "Renzo", last_name: "Trentini", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "ddainese@shado.tv", first_name: "Costantino", last_name: "Cocci", 
						privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")
						
User.create(email: "mpozzana@shado.tv", first_name: "Gualtiero", last_name: "Fallaci", 
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "fragazzo@shado.tv", first_name: "Aladino", last_name: "Lucchesi", 
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "anonymous@shado.tv", first_name: "Anonymous", last_name: "Anonymous", 
						privacy: true, password: "shado00", password_confirmation: "shado00")


						
Setting.create(key: "rewarding.rules", value: <<-EOF
rule "PLAY_VIDEO",
  interactions: { types: ["Play"] },  
  rewards: [{ "point" => 5 }]

rule "QUIZ_ANSWER",
  interactions: { types: ["Quiz"] },
  rewards: [{ "point" => 10 }] 

rule "QUIZ_CORRECT",
  interactions: { types: ["Quiz"] },
  rewards: [{ "point" => 15 }] { 
    correct_answer
  }
EOF
)

Reward.create(name: "point", title: "Points", countable: true, numeric_display: true)