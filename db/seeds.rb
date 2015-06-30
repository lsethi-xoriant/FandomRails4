User.create(email: "atolomio@shado.tv", first_name: "Martino", last_name: "Russo", username: "atolomio@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "sbartolucci@shado.tv", first_name: "Renzo", last_name: "Trentini", username: "sbartolucci@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "ddainese@shado.tv", first_name: "Costantino", last_name: "Cocci", username: "ddainese@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")
            
User.create(email: "mpozzana@shado.tv", first_name: "Gualtiero", last_name: "Fallaci", username: "mpozzana@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "fragazzo@shado.tv", first_name: "Aladino", last_name: "Lucchesi", username: "fragazzo@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00", role: "admin")

User.create(email: "anonymous@shado.tv", first_name: "Anonymous", last_name: "Anonymous", username: "anonymous@shado.tv",
            privacy: true, password: "shado00", password_confirmation: "shado00")


Tag.create(name: "basic", description: "serve per nascondere i badge e livelli dalla pagina catalogo premi", locked: true)

Tag.create(name: "top", description: "serve per posizionare gli elementi in alto e in evidenza all'interno della pagina catalogo premi", locked: true)

Tag.create(name: "level", description: "serve per creare i livelli", locked: true)

Tag.create(name: "template", description: "serve per impostare le cta come template da poter replicare durante il data entry successivo al setup iniziale", locked: true)

Tag.create(name: "miniformat", description: "serve per poter visualizzare l'icona di un tag specifico in una singola cta o nel menu che filtra le cta.", locked: true)

Tag.create(name: "gallery", description: "serve per poter abilitare la gallery", locked: true)

Tag.create(name: "sidebar-home", description: "", locked: true)

Tag.create(name: "assets", description: "", locked: true)

Tag.create(name: "menu-item", description: "", locked: true)

Setting.create(key: "rewarding.rules", value: <<-EOF
EOF
)

Reward.create(name: "point", title: "point", countable: true, numeric_display: true)

