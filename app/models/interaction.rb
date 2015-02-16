#!/bin/env ruby
# encoding: utf-8

class Interaction < ActiveRecord::Base
  attr_accessible :name, :resource, :resource_id, :resource_type, :seconds, :call_to_action_id, :resource_attributes,
    :points, :added_points, :when_show_interaction, :required_to_complete, :stored_for_anonymous
  
  belongs_to :resource, polymorphic: true, dependent: :destroy
  belongs_to :call_to_action

  has_many :user_interactions, dependent: :destroy
  has_many :interaction_call_to_actions

  before_create :check_name

  validate :resource_errors
  validate :check_max_one_play_resource
  validate :check_max_one_comment_resource

  def when_show_interaction_enum
    ["SEMPRE_VISIBILE", "OVERVIDEO_DURING", "OVERVIDEO_START", "OVERVIDEO_END", "MAI_VISIBILE"]
  end

  def points_type_enum
    ["CUSTOM", "DEFAULT"]
  end

  def check_name
    name = "#inter#{ Interaction.count }" if name.blank?
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
      self.resource.update_attributes(attributes.except(:id)) 
    end
  end

end
