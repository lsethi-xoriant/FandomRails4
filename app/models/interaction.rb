#!/bin/env ruby
# encoding: utf-8

class Interaction < ActiveRecord::Base
  attr_accessible :name, :resource, :resource_id, :resource_type, :seconds, :call_to_action_id, :resource_attributes,
    :when_show_interaction, :required_to_complete, :stored_for_anonymous, :aux, :registration_needed,
    :interaction_positioning, :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id,
    :twitter_registered_users_only, :instagram_registered_users_only, :facebook_page_id, :facebook_to_be_approved
  attr_accessor :gallery_type, :instagram_tag_name, :twitter_tag_name, :instagram_tag_subscription_id, 
    :twitter_registered_users_only, :instagram_registered_users_only, :facebook_page_id, :facebook_to_be_approved
  
  belongs_to :resource, polymorphic: true, dependent: :destroy
  belongs_to :call_to_action

  has_many :user_interactions, dependent: :destroy
  has_many :interaction_call_to_actions

  before_create :check_name
  before_save :default_values, :set_upload_type

  validate :resource_errors
  validate :check_max_one_play_resource
  validate :check_max_one_comment_resource

  before_update :set_social_tag_in_interaction_aux

  def set_social_tag_in_interaction_aux
    if self.gallery_type == "instagram" || self.gallery_type == "twitter" || self.gallery_type == "facebook"
      aux = self.aux || {}
      aux["configuration"] = { "type" => self.gallery_type }
      if self.gallery_type == "facebook"
        tag_info = {
          "facebook_page" => {
            "id" => self.facebook_page_id, 
            "to_be_approved" => self.facebook_to_be_approved == "1"
          }
        }
      elsif self.gallery_type == "instagram"
        tag_info = {
          "instagram_tag" => {
            "name" => self.instagram_tag_name, 
            "subscription_id" => self.instagram_tag_subscription_id,
            "registered_users_only" => (self.instagram_registered_users_only == "1" )
          }
        }
      elsif self.gallery_type == "twitter"
        tag_info = {
          "twitter_tag" => {
            "name" => self.twitter_tag_name,
            "registered_users_only" => (self.twitter_registered_users_only == "1")
          }
        }
      end
      aux["configuration"].merge!(tag_info)
    end
  end

  def when_show_interaction_enum
    WHEN_SHOW_USER_INTERACTION
  end

  def points_type_enum
    ["CUSTOM", "DEFAULT"]
  end

  def check_name
    name = "#inter#{ Interaction.count }" if name.blank?
  end

  def default_values
    if self.aux.blank? 
      self.aux = "{}"
    end
  end

  def set_upload_type
    if self.resource_type == "Upload"
      upload_aux = { "configuration" => { "type" => self.gallery_type } }
      self.aux = upload_aux.merge(self.aux)
      if self.gallery_type == "instagram"
        self.when_show_interaction = "MAI_VISIBILE"
      end
    end
  end

  # Ogni calltoaction (per il momento formata da un solo media), può avere una sola interaction di tipo Play. Un'interaction
  # di tipo Play può essere utilizzata per assegnare punti o semplicemente per tracciare le view.
  def check_max_one_play_resource
    errors.add("calltoaction_id", "ogni interaction può avere al massimo un interaction di tipo Play") if id.blank? && call_to_action && resource_type == "Play" && call_to_action.interactions.find_by_resource_type("Play")
  end

  # Ogni calltoaction può contenere una solo interazione di tipo Comment.
  def check_max_one_comment_resource
    errors.add("calltoaction_id", "ogni interaction può avere al massimo un interaction di tipo Comment") if id.blank? && call_to_action && resource_type == "Comment" && call_to_action.interactions.find_by_resource_type("Comment")
  end

  # Validazione per gestire gli errori nel accepts_nested_attributes_for con polimorfismo.
  def resource_errors
    unless resource.nil? || resource.valid?
      resource.save # Per poter visualizzare gli errori.
      if resource.errors.any?
        resource.errors.each do |key, message|
          case key.to_s
          when 'question'
            errors.add("- Domanda:", message)
          when 'answers'
            errors.add("- Risposta:", message)
          else
            errors.add("- resource.#{key}:", message)
          end
        end
      end
    end
  end

  def attributes=(attributes = {})
    self.resource_type = attributes[:resource_type]
    super
  end

  # Override del resource_attributes per gestire il accepts_nested_attributes_for con polimorfismo.
  def resource_attributes=(attributes)
    if attributes[:id].blank?
      self.resource = eval(resource_type).new(attributes)
    else
      self.resource = eval(resource_type).find(attributes[:id])
      self.resource.update_attributes(attributes.except(:id, :linked_cta)) 
    end
  end

end
