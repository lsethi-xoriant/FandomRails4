class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # User not logged.
    if user && user.role == "admin"
      can :manage, :all 
      can :access, :rails_admin
      can :dashboard
    elsif user && user.role == "editor"
      can :access, :easyadmin 
    elsif user && user.role == "viewer"
      can :access, :easyadmin 
    elsif user && user.role == "comment-moderator"
      can :access, :easyadmin 
      can :manage, :comments
    end
    
  end
end
