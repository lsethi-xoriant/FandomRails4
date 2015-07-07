class Upload < ActiveRecord::Base
  attr_accessible :call_to_action_id, :releasing, :releasing_description, :privacy, :privacy_description, :upload_number, 
                  :watermark, :title_needed, :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id, :registered_users_only
  attr_accessor :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id, :registered_users_only

  has_one :interaction, as: :resource
  belongs_to :call_to_action
  has_many :user_upload_interactions

  after_update :set_instagram_tag_in_interaction_aux

  has_attached_file :watermark, :styles => { :normalized => "200x112#" }
  do_not_validate_attachment_file_type :watermark

  def set_instagram_tag_in_interaction_aux
    if self.gallery_type == "instagram"
      interaction = self.interaction
      aux = interaction.aux || {}
      aux["configuration"] = { 
        "type" => "instagram", 
        "instagram_tag" => { 
          "name" => self.instagram_tag_name, 
          "subscription_id" => self.instagram_tag_subscription_id,
          "registered_users_only" => self.registered_users_only == "1"
          } 
        }
      interaction.update_attribute(:aux, aux)
    end
  end

  def one_shot
    false
  end

end

