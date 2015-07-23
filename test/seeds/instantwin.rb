# Player creation
user_params = { email: "player@shado.tv", first_name: "Player", last_name: "Test", username: "player@shado.tv", privacy: true }
user = User.where(user_params).first
if user.nil?
  user = User.create(user_params.merge({ :password => "shado00", :password_confirmation => "shado00" }))
end

# Reward ticket, instantwin interaction, call to action, interaction and prize reward creation
contest_reward_ticket = Reward.where(:title => "Instantwin ticket", :name => "instantwin-currency").first_or_create
contest_reward_ticket_id = contest_reward_ticket.id

contest_instantwin_interaction = InstantwinInteraction.where(:currency_id => contest_reward_ticket_id).first
if contest_instantwin_interaction.nil?
  contest_instantwin_interaction = InstantwinInteraction.new()
  contest_instantwin_interaction.reward = contest_reward_ticket
  contest_instantwin_interaction.save
end
contest_instantwin_interaction_id = contest_instantwin_interaction.id

contest_call_to_action = CallToAction.where(:title => "Instantwin Call to Action", :name => "instantwin-call-to-action", :valid_from => DateTime.parse("2015-01-01T00:00:00"), :valid_to => DateTime.parse("2015-01-31T23:59:59")).first_or_create

contest_interaction = Interaction.where(:resource_type => "InstantwinInteraction", :resource_id => contest_instantwin_interaction_id, :call_to_action_id => contest_call_to_action.id).first_or_create

contest_reward = Reward.where(:title => "Instantwin prize", :name => "instantwin-prize").first_or_create
contest_reward_id = contest_reward.id

# Assign some ticket to user
user_reward = UserReward.where(:user_id => user.id, :reward_id => contest_reward_ticket_id).first_or_create
user_reward.update_attribute(:counter, 200)

# Instantwins

# Set winning interval for each instantwin
instantwins_info = [
  { :valid_from => "2015-01-01T10:00:00", :valid_to => "2015-01-01T10:10:00" }, 
  { :valid_from => "2015-01-01T10:30:00", :valid_to => "2015-01-01T10:40:00" }, 
  { :valid_from => "2015-01-01T10:35:00", :valid_to => "2015-01-01T10:45:00" }
]

reward_info = {}
instantwins = []
instantwins_info.each_with_index do |instantwin, i|
  instantwin_params = { 
    :valid_from => DateTime.parse(instantwin[:valid_from]), 
    :valid_to => DateTime.parse(instantwin[:valid_to]), 
    :won => false, 
    :instantwin_interaction_id => contest_instantwin_interaction_id 
  }

  instantwin = Instantwin.where(instantwin_params).first
  if instantwin.nil?
    instantwins << Instantwin.create(instantwin_params.merge({ :reward_info => { :reward_id => contest_reward_id, :prize_code => "instantwin_prize_#{i}" } }))
  else
    instantwins << instantwin
  end
end

# [contest_reward_ticket, contest_instantwin_interaction, contest_call_to_action, contest_interaction, user, contest_reward].each do |m|
#   puts m.errors.messages
# end

[contest_call_to_action, contest_interaction, user]

# puts Instantwin.all.to_a.map(&:serializable_hash)
