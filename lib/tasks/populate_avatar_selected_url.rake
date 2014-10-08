namespace :avatar_url do

  desc "Populates avatar_selected_url column of users table"
  task :populate => :environment do
  	populate
  end
  
  def populate
    Apartment::Tenant.switch("ballando")
    User.all.each do |user|
      case user.avatar_selected
        when "upload"
          avatar = user.avatar ? user.avatar(:thumb) : "/assets/anon.png"
        when "facebook"
          avatar = user.authentications.find_by_provider("facebook").avatar
        when "twitter"
          avatar = user.authentications.find_by_provider("twitter").avatar#.gsub("_normal","_#{ size }")
      end
      user.update_attribute(:avatar_selected_url, avatar)
      puts "============ utente: #{user.email}, avatar: #{avatar} ============"
    end
  end
  
end