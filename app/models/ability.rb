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
    end
    
  end
end
