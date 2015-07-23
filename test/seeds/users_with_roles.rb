{ 
  "admin" => User.where(:email => "admin@test.com", :first_name => "Admin", :role => "admin").first_or_create, 
  "editor" => User.where(:email => "editor@test.com", :first_name => "Editor", :role => "editor").first_or_create, 
  "moderator" => User.where(:email => "moderator@test.com", :first_name => "Moderator", :role => "moderator").first_or_create, 
  "viewer" => User.where(:email => "viewer@test.com", :first_name => "Viewer", :role => "viewer").first_or_create
}