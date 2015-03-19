class Ability

  # List of custom abilities:
  # :access, :rails_admin, :easyadmin, :dashboard
  # :manage, :all - :users - :published - :carousel - :call_to_actions - :user_call_to_actions
  #           :promocodes - :rewards - :tags - :comments - :notices - :rankings - :settings

  include CanCan::Ability

  def initialize(user)

    user ||= User.new # User not logged.
    if user && user.role == "admin"
      can :manage, :all 
      can :access, :rails_admin
    elsif user && user.role == "editor"
      can :manage, :all 
      cannot :manage, :rewards
      cannot :manage, :rankings
      cannot :manage, :settings
    elsif user && user.role == "viewer"
      can :access, :easyadmin
      can :access, :dashboard
      can :manage, :users
    elsif user && user.role == "moderator"
      can :access, :easyadmin
      can :manage, :user_call_to_actions
      can :manage, :comments
    end
    
  end
end
