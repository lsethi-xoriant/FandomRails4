password = { password: "shado00", password_confirmation: "shado00" }

users_params = [
  { email: "atolomio@shado.tv", first_name: "Martino", last_name: "Russo", username: "atolomio@shado.tv", privacy: true, role: "admin" },
  { email: "sbartolucci@shado.tv", first_name: "Renzo", last_name: "Trentini", username: "sbartolucci@shado.tv", privacy: true, role: "admin" },
  { email: "ddainese@shado.tv", first_name: "Costantino", last_name: "Cocci", username: "ddainese@shado.tv", privacy: true, role: "admin" },
  { email: "mpozzana@shado.tv", first_name: "Gualtiero", last_name: "Fallaci", username: "mpozzana@shado.tv", privacy: true, role: "admin" },
  { email: "fragazzo@shado.tv", first_name: "Aladino", last_name: "Lucchesi", username: "fragazzo@shado.tv", privacy: true, role: "admin" },
  { email: "anonymous@shado.tv", first_name: "Anonymous", last_name: "Anonymous", username: "anonymous@shado.tv", privacy: true }
]

Tag.where(name: "basic", description: "serve per nascondere i badge e livelli dalla pagina catalogo premi", locked: true).first_or_create
Tag.where(name: "top", description: "serve per posizionare gli elementi in alto e in evidenza all'interno della pagina catalogo premi", locked: true).first_or_create
Tag.where(name: "level", description: "serve per creare i livelli", locked: true).first_or_create
Tag.where(name: "template", description: "serve per impostare le cta come template da poter replicare durante il data entry successivo al setup iniziale", locked: true).first_or_create
Tag.where(name: "miniformat", description: "serve per poter visualizzare l'icona di un tag specifico in una singola cta o nel menu che filtra le cta.", locked: true).first_or_create
Tag.where(name: "gallery", description: "serve per poter abilitare la gallery", locked: true).first_or_create


Setting.where(key: "rewarding.rules", value: <<-EOF
EOF
).first_or_create

Reward.where(name: "point", title: "point", countable: true, numeric_display: true).first_or_create

call_to_action_for_registration = CallToAction.where(:name => "call-to-action-for-registration", :title => "Call to Action for registration").first_or_create
basic_interaction_resource_for_registration = Basic.where({ :basic_type => "Registration" }).first_or_create
basic_interaction_for_registration = Interaction.where({ :resource_id => basic_interaction_resource_for_registration.id, :resource_type => "Basic", :call_to_action_id => call_to_action_for_registration.id }).first_or_create

users = []
users_params.each do |user_params|
  users << (User.where(user_params).first || User.create(user_params.merge(password)))
end
users