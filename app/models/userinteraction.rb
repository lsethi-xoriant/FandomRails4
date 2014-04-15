class Userinteraction < ActiveRecord::Base
  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter, :points, :added_points

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode

  # Aggiorno tutti i valori in cache delle interaction ogni volta che aggiorno una userinteraction.
  before_save :update_interaction_counter

  after_create :update_rewarding_user # Ogni volte che compio una NUOVA azione aggiorno i punti utente.

  # Alla creazione salvo anche i punti che quella interaction mi ha dato. I punti non possono essere modificati.
  before_create :update_ui_points

  after_destroy :update_interaction_counter_down
  after_destroy :update_rewarding_user_down

  validates_uniqueness_of :interaction_id, :scope => :user_id, if: Proc.new { |ui| ui.user_id != (-1) }

  def update_ui_points
    # Tengo traccia di quanti PUNTI valeva l'interazione nel momento in cui ho giocato.
    if interaction.resource_type == "Share"
      self.points = check_already_share_cta? ? 0 : interaction.points
    else
      self.points = interaction.points
      self.added_points = interaction.added_points
    end
  end

  def update_interaction_counter
    # Un utente puo' inserire un LIKE o UNLIKE ma la UserInteraction non viene cancellata per evitare che i punti
    # vengano assegnati piu' volte. Ci si basa sul valore del counter 1 per il LIKE o 0 per l'UNLIKE.
    if interaction.resource_type == "Like" && counter > 0
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    elsif interaction.resource_type == "Like" && counter < 1
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Play"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Promocode"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Share"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Download"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Check"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "VERSUS"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end

    if interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "TRIVIA"
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
      if answer && answer.correct
        interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer + 1)
      elsif answer && answer.correct.blank?
        interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer + 1)
      end
    end

  end

  def update_interaction_counter_down
    # Se vengono eliminate delle UserInteraction devo aggiornare di conseguenza i vari conteggi per mantenere
    # i valori consistenti.
    if interaction.resource_type == "Play"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - counter)
    end

    if interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "VERSUS"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Like"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Promocode"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Check"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Download"
      interaction.resource.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Share"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end

    if interaction.resource_type == "Quiz" && interaction.resource.quiz_type == "TRIVIA"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      if answer && answer.correct
        interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer - 1)
      elsif answer && answer.correct.blank?
        interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer - 1)
      end
    end

  end

  def update_rewarding_user
    if user && (user != -1)
      property_id = interaction.resource_type == "Promocode" ? interaction.resource.property_id : interaction.calltoaction.property_id
      unless (ru = user.rewarding_users.find_by_property_id(property_id))
        ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
      end

      if self.points > 0
         # I CREDITI aumentano di pari passo con i PUNTI.
        points_for_user = answer_id && answer.correct ? (self.points + self.added_points) : self.points
        ru.update_attributes(points: (ru.points + points_for_user), credits: (ru.credits + points_for_user))
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
      property_id = interaction.resource_type == "Promocode" ? interaction.resource.property_id : interaction.calltoaction.property_id
      unless (ru = user.rewarding_users.find_by_property_id(property_id))
        ru = RewardingUser.create(user_id: user.id, property_id: (property_id))
      end

      if self.points > 0
         # Viene considerato che i CREDITI aumentano insieme ai PUNTI.
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

  # Restituisce se la calltoaction e' gia' stata condivisa con un altro tipo di provider.
  def check_already_share_cta?
    return Userinteraction.includes(:interaction).where("interactions.resource_type='Share' AND user_id=?", user_id).any?
  end
  
end
