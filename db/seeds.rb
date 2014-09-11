## CREAZIONE UTENTI AMMINISTRATORI DI DEFAULT ##

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


## DEFINIZIONE TAG ##

Tag.create(name: "basic", description: "serve per nascondere i badge e livelli dalla pagina catalogo premi", locked: true)

Tag.create(name: "top", description: "serve per posizionare gli elementi in alto e in evidenza all'interno della pagina catalogo premi", locked: true)

Tag.create(name: "level", description: "serve per creare i livelli", locked: true)

Tag.create(name: "template", description: "serve per impostare le cta come template da poter replicare durante il data entry successivo al setup iniziale", locked: true)

Tag.create(name: "miniformat", description: "serve per poter visualizzare l'icona di un tag specifico in una singola cta o nel menu che filtra le cta.", locked: true)

Tag.create(name: "gallery", description: "serve per poter abilitare la gallery", locked: true)


## DEFINIZIONE REGOLE DI REWARD ##

Setting.create(key: "rewarding.rules", value: <<-EOF

rule "TRIVIA_ANSWER",
  interactions: { types: ["Trivia"] },
  rewards: [{ "point" => 1,  "credit" => 1}] 

rule "TRIVIA_CORRECT",
  interactions: { types: ["Trivia"] },
  rewards: [{ "point" => 3, "credit" => 2}] { 
    correct_answer
  }

rule "VERSUS_ANSWER",
  interactions: { types: ["Versus"] },
  rewards: [{ "point" => 1, "credit" => 1 }] 

rule "CHECK_ANSWER",
  interactions: { types: ["Check"] },
  rewards: [{ "point" => 1, "credit" => 1 }]

rule "SHARE",
  interactions: { types: ["Share"] },
  rewards: [{ "point" => 1, "credit" => 1 }] 

rule "LIKE",
  interactions: { types: ["Like"] },
  rewards: [{ "point" => 1, "credit" => 1 }]

rule "DOWNLOAD",
  interactions: { types: ["Download"] },
  rewards: [{ "point" => 1, "credit" => 1}]

EOF
)

## DEFINIZIONE REWARD di tipo BADGE ##

Reward.create(name: "point", title: "point", countable: true, numeric_display: true)

Reward.create(name: "credit", title: "credit", spendable: true, countable: true, numeric_display: true)

Reward.create(name: "trivia1", title: "trivia1", short_description: "Per ottenere questo badge è sufficiente rispondere ad un trivia", long_description: "Per ottenere questo badge è sufficiente rispondere ad un trivia")

Reward.create(name: "trivia3", title: "trivia3", short_description: "Per ottenere questo badge è sufficiente rispondere a tre trivia", long_description: "Per ottenere questo badge è sufficiente rispondere a tre trivia")

Reward.create(name: "versus1", title: "versus1", short_description: "Per ottenere questo badge è sufficiente rispondere a un versus", long_description: "Per ottenere questo badge è sufficiente rispondere a un versus")

Reward.create(name: "versus3", title: "versus3", short_description: "Per ottenere questo badge è sufficiente rispondere a tre versus", long_description: "Per ottenere questo badge è sufficiente rispondere a tre versus")

Reward.create(name: "share1", title: "share1", short_description: "Per ottenere questo badge è sufficiente condividere un contenuto", long_description: "Per ottenere questo badge è sufficiente condividere un contenuto")

Reward.create(name: "share3", title: "share3", short_description: "Per ottenere questo badge è sufficiente condividere tre contenuti", long_description: "Per ottenere questo badge è sufficiente condividere tre contenuti")

Reward.create(name: "download1", title: "download1", short_description: "Per ottenere questo badge è sufficiente effettuare un download di un contenuto", long_description: "Per ottenere questo badge è ssufficiente effettuare un download di un contenuto")

Reward.create(name: "download3", title: "download3", short_description: "Per ottenere questo badge è sufficiente effettuare un download di tre contenuto", long_description: "Per ottenere questo badge è sufficiente effettuare un download di tre contenuti")
