class Upload < ActiveRecord::Base
  attr_accessible :call_to_action_id, :releasing, :releasing_description, :privacy, :privacy_description, :upload_number, 
                  :watermark, :title_needed, :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id, :registered_users_only
  attr_accessor :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id, :registered_users_only

  has_one :interaction, as: :resource
  belongs_to :call_to_action
  has_many :user_upload_interactions

  after_update :set_social_tag_in_interaction_aux

  has_attached_file :watermark, :styles => { :normalized => "200x112#" }
  do_not_validate_attachment_file_type :watermark

  def set_social_tag_in_interaction_aux
    if self.gallery_type == "instagram" || self.gallery_type == "twitter"
      interaction = self.interaction
      aux = interaction.aux || {}
      aux["configuration"] = { "type" => self.gallery_type }
      if self.gallery_type == "instagram"
        tag_info = {
          "instagram_tag" => {
            "name" => self.instagram_tag_name, 
            "subscription_id" => self.instagram_tag_subscription_id,
            "registered_users_only" => self.registered_users_only == "1" 
          }
        }
      elsif self.gallery_type == "twitter"
        tag_info = {
          "twitter_tag" => {
            "name" => self.twitter_tag_name,
            "registered_users_only" => self.registered_users_only == "1" 
          }
        }
      end
      aux["configuration"].merge!(tag_info)
      interaction.update_column(:aux, aux)
    end
  end

  def one_shot
    false
  end

end