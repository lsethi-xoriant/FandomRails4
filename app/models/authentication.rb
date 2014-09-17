class Authentication < ActiveRecord::Base
  	attr_accessible :uid, :name, :oauth_token, :oauth_secret, :oauth_expires_at, :user_id, :provider, :avatar, :aux
 
  	belongs_to :user

  	after_destroy :upload_avatar_selected, :if => proc {|c| self.user.avatar_selected == self.provider }
  	before_update :upload_avatar_selected_user_before, :if => proc {|c| user_id_was != user_id }

  	# Per abilitare la pubblicazione in corrispondenza della prima registrazione.
  	# after_create :publish_on_fb
   	def publish_on_fb
	   	begin
		   	me = FbGraph::User.me(oauth_token)
		   	me.feed!(
		   		:message => "",
		   		:picture => "indirizzo immagine",
		   		:link => "indirizzo applicazione",
		   		:name => "",
		   		:description => ""
		   	)
		rescue Exception
			# Condivisione non andata a buon fine.
		end
  	end # publish_on_fb 

  	def upload_avatar_selected_user_before
  		user_was = User.find(user_id_was)
  		User.find(user_id_was).update_attribute(:avatar_selected, "upload") if user_was && user_was.avatar_selected == self.provider
  	end

  	def upload_avatar_selected
  		# Se l'utente sta utilizzando l'immagine del provider che sto andando ad eliminare, imposto come
  		# immagine quella caricata, se non esiste viene usata quella di default.
  		self.user.update_attribute(:avatar_selected, "upload")
  	end # upload_avatar_selected
end