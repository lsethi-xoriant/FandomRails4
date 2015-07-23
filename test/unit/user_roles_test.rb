require "test_helper"

class UserRolesTest < ActiveSupport::TestCase

  def setup
    switch_tenant("fandom")
    @users = load_seed("users_with_roles")
  end

  test "user_abilities" do

    @users.each do |role, user|
      verify_ability(user, :access, :rails_admin, ["Admin"])
      verify_ability(user, :access, :easyadmin, ["All"])
      verify_ability(user, :access, :dashboard, ["Admin", "Editor", "Viewer"])
      verify_ability(user, :read, :users, ["Admin", "Editor", "Viewer"])

      verify_ability(user, :manage, :all, ["Admin", "Editor"])
      verify_ability(user, :manage, :users, ["Admin"])
      verify_ability(user, :manage, :published, ["Admin", "Editor"])
      verify_ability(user, :manage, :carousel, ["Admin", "Editor"])
      verify_ability(user, :manage, :call_to_actions, ["Admin", "Editor"])
      verify_ability(user, :manage, :user_call_to_actions, ["Admin", "Editor", "Moderator"])
      verify_ability(user, :manage, :promocodes, ["Admin", "Editor"])
      verify_ability(user, :manage, :rewards, ["Admin"])
      verify_ability(user, :manage, :tags, ["Admin", "Editor"])
      verify_ability(user, :manage, :comments, ["Admin", "Editor", "Moderator"])
      verify_ability(user, :manage, :notices, ["Admin", "Editor"])
      verify_ability(user, :manage, :rankings, ["Admin"])
      verify_ability(user, :manage, :settings, ["Admin"])
    end

  end

  def verify_ability(user, action, argument, authorized_list)
    ability = Ability.new(user)
    user_name = user.first_name

    if authorized_list.include?(user_name) || authorized_list.include?("All")
      assert ability.can?(action, argument), "#{user_name} shouldn't be able to #{action} #{argument}!"
    else
      assert_not ability.can?(action, argument), "#{user_name} should be able to #{action} #{argument}!"
    end
  end

end