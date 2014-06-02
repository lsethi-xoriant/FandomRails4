include ApplicationHelper
include InstantwinHelper
include FandomUtils

class Userinteraction < ActiveRecord::Base
  # TODO: check if after create an userinteraction cached values are update correctly.

  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter, :points, :added_points

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode

  # Update all cache interaction value each time a userinteraction is updated or created.
  before_save :update_interaction_counter

  # Update user profile each time an user do an action.
  after_create :update_rewarding_user

  before_create :init_ui_points

  after_destroy :update_interaction_counter_down
  after_destroy :update_rewarding_user_down

  # Move in controller.
  # def check_interaction_limit_daily
  #   uicount = Userinteraction.where("user_id=? AND interaction_id=? AND created_at<=? AND created_at>=?", 
  #     user_id, interaction_id, DateTime.now.utc.change(hour: 23).change(min: 59).change(sec: 59), DateTime.now.utc.change(hour: 0).change(min: 0).change(sec: 0)).count
  #   errors.add(:limit_exceeded, "hai raggiunto il limite giornaliero di inviti") if uicount > 4
  # end

  def update_invite_points
    property_id = interaction.resource.property_id
    unless (ru = user.rewarding_users.find_by_property_id(property_id))
      ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
    end

    if self.points > 0
      points_for_user = points - points_was
      ru.update_attributes(points: (ru.points + points_for_user), credits: (ru.credits + points_for_user))
    end
  end

  def update_invite_added_points
    property_id = interaction.resource.property_id
    unless (ru = user.rewarding_users.find_by_property_id(property_id))
      ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
    end

    if self.points > 0
      points_for_user = added_points - added_points_was
      ru.update_attributes(points: (ru.points + points_for_user), credits: (ru.credits + points_for_user))
    end
  end

  def init_ui_points
    if interaction.resource_type == "Share"
      self.points = check_already_share_cta? ? 0 : interaction.points
    else
      self.points = interaction.points
      if interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "TRIVIA" && self.answer.correct
        self.added_points = interaction.added_points 
      end
    end
  end

  def update_interaction_counter
    case interaction.resource_type
    when "Like"
      if counter > 0
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
      elsif counter < 1
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      end
    when "Quiz"
      if interaction.resource.quiz_type == "VERSUS"
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
      elsif interaction.resource.quiz_type == "TRIVIA"
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
        if answer && answer.correct
          interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer + 1)
        elsif answer && answer.correct.blank?
          interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer + 1)
        end
      end
    else
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end
  end

  def update_interaction_counter_down
    case interaction.resource_type
    when "Like"
      if counter > 0
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      end
    when "Play"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - counter)
    when "Quiz"
      if interaction.resource.quiz_type == "VERSUS"
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      elsif interaction.resource.quiz_type == "TRIVIA"
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
        if answer && answer.correct
          interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer - 1)
        elsif answer && answer.correct.blank?
          interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer - 1)
        end
      end
    else
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end
  end

  def update_rewarding_user
    if user && (user != -1)
      property_id = interaction.calltoaction.property_id
      unless (ru = user.rewarding_users.find_by_property_id(property_id))
        ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
      end

      if self.points > 0
        points_for_user = answer_id && answer.correct ? (self.points + self.added_points) : self.points
        ru.update_attributes(points: (ru.points + points_for_user), credits: (ru.credits + points_for_user))

        InstantwinHelper.update_contest_points user.id, points_for_user
      end

      case interaction.resource_type
      when "Quiz" 
        if interaction.resource.quiz_type == "TRIVIA"
          if answer && answer.correct
            ru.update_attribute(:trivia_right_counter, ru.trivia_right_counter + 1)
          elsif answer && answer.correct.blank?
            ru.update_attribute(:trivia_wrong_counter, ru.trivia_wrong_counter + 1)
          end
        elsif interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "VERSUS"
          ru.update_attribute(:versus_counter, ru.versus_counter + 1)
        end
      when "Play"
        ru.update_attribute(:play_counter, ru.play_counter + 1)
      when "Like"
        ru.update_attribute(:like_counter, ru.like_counter + 1)
      when "Check"
        ru.update_attribute(:check_counter, ru.check_counter + 1)
      end
      
    end
  end

  def update_rewarding_user_down
    if user && (user != -1)
      # Aggiorno il RewardingUser, alcune azioni vengono tracciate anche per l'utente anonimo.
      property_id = interaction.calltoaction.property_id
      unless (ru = user.rewarding_users.find_by_property_id(property_id))
        ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
      end

      if self.points > 0
        points_for_user = answer_id && answer.correct ? (self.points + self.added_points) : self.points
        ru.update_attributes(points: (ru.points - points_for_user), credits: (ru.credits - points_for_user))
      end

      case interaction.resource_type
      when "Quiz"
        if interaction.resource.quiz_type == "TRIVIA"
          if answer && answer.correct
            ru.update_attribute(:trivia_right_counter, ru.trivia_right_counter - 1)
          elsif answer && answer.correct.blank?
            ru.update_attribute(:trivia_wrong_counter, ru.trivia_wrong_counter - 1)
          end
        elsif interaction.resource.quiz_type == "VERSUS"
          ru.update_attribute(:versus_counter, ru.versus_counter - 1)
        end
      when "Play"
        ru.update_attribute(:play_counter, ru.play_counter - 1)
      when "Like"
        ru.update_attribute(:like_counter, ru.like_counter - 1)
      when "Check"
        ru.update_attribute(:check_counter, ru.check_counter - 1)
      end

    end
  end

  private

  # Return TRUE if the current calltoaction is already shared.
  def check_already_share_cta?
    share_inter = self.interaction.calltoaction.interactions.where("resource_type='Share'")
    return !self.user.userinteractions.where("interaction_id in (?)", share_inter.map.collect { |u| u["id"] }).blank?
  end  
end

