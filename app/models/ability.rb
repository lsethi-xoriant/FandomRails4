# Public: Class useful to define user permissions for CanCan gem usage.
# CanCan documentation at https://github.com/ryanb/cancan.
class Ability

  include CanCan::Ability

# Public: Initialize user permissions
# List of custom abilities: 
# :access, :rails_admin - :easyadmin - :dashboard
# :manage, :all - :users - :published - :carousel - :call_to_actions - :user_call_to_actions
#          :promocodes - :rewards - :tags - :comments - :notices - :rankings - :settings
#
# Examples
# 
#   before_filter :authorize_user
#   def authorize_user
#     authorize! :manage, :rewards
#   end
#   ...
#
#   def dashboard
#     authorize! :access, :dashboard
#     ...
#
# user - The User trying to access a page or using a method that requires permissions.
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
      cannot :manage, :users
      can :read, :users
    elsif user && user.role == "moderator"
      can :access, :easyadmin
      can :manage, :user_call_to_actions
      can :manage, :comments
    elsif user && user.role == "viewer"
      can :access, :easyadmin
      can :access, :dashboard
      can :read, :users
    end
 
  end
end
