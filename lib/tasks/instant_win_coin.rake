namespace :instant_win_coin do
  #require 'digest/md5'
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  desc "Genera tutte le data e ora di vincita del concorso"
  task :generate => :environment do
  	createWins
  end
  
  def initContest
    Apartment::Database.switch("coin")
    ticket = Reward.create(
      title: "ticket", 
      short_description: "ticket reward per giocare agli instantwin", 
      button_label: "Gioca e vinci", 
      media_type: "DIGITALE", 
      countable: true, 
      name: "ticket"
    )
    gift_500 = Reward.create(
      title: "Gift Card Coin 500 Euro", 
      short_description: "1 Gift Card Coin 500 Euro", 
      media_type: "DIGITALE", 
      name: COIN_GIFT_500['name']
    )
    gift_100 = Reward.create(
      title: "Gift Card Coin 100 Euro", 
      short_description: "1 Gift Card Coin 100 Euro", 
      media_type: "DIGITALE", 
      name: COIN_GIFT_100['name']
    )
    gift_50 = Reward.create(
      title: "Gift Card Coin 50 Euro", 
      short_description: "1 Gift Card Coin 50 Euro", 
      media_type: "DIGITALE", 
      name: COIN_GIFT_50['name']
    )
    
    contest_prize_list = create_contest_prize_list()
    
    contest = CallToAction.create(
      name: "coin_contest",
      title: "Concorso Coin",
      description: "Il concorso di Coin",
      valid_from: Time.parse(COIN_CONTEST_START_DATE),
      valid_to: Time.parse(COIN_CONTEST_END_DATE)
    )
    instantwin_interaction = InstantwinInteraction.create(
      reward_id: ticket.id
    )
    interaction = Interaction.new(
      name: "instantwin_interaction",
      when_show_interaction: "SEMPRE_VISIBILE",
      call_to_action_id: contest.id
    )
    interaction.resource = instantwin_interaction
    interaction.save
    
    [contest_prize_list, instantwin_interaction, contest]
    
  end
  
  def create_contest_prize_list
    prize_list = Array.new
    COIN_PRIZES_LIST.each do |p|
      reward = Reward.find_by_name(p['name'])
      p['qta'].times do |i|
        prize_list << reward.id
      end
    end
    prize_list.shuffle
  end
  
  def get_start_hour_for_instantwin(cdate, contest)
    if(cdate == contest.valid_from.to_date)
      hour = (contest.valid_from.hour.to_i..23).to_a.sample
    elsif(cdate == contest.valid_to.to_date)
      hour = (0..contest.valid_to.hour.to_i).to_a.sample
    else
      hour = (0..23).to_a.sample
    end
  end
  
  def createWins
    prizes, iw_interaction, contest = initContest
    cdate = contest.valid_from.to_date
    hash_counter = 1
    while cdate <= contest.valid_to.to_date
      hour = get_start_hour_for_instantwin(cdate, contest)
      time = "#{hour}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} Rome"
      wintime = Time.parse(cdate.strftime("%Y-%m-%d") +" "+ time)
      wintime_end = wintime.end_of_day
      
      unique_id = Digest::MD5.hexdigest("#{hash_counter}")
      while Instantwin.where("(reward_info->>'prize_code') = ?",unique_id).present?
        hash_counter += 1
        unique_id = Digest::MD5.hexdigest("#{hash_counter}")
      end
      
      reward_id = get_instantwin_reward(prizes)
      reward_info = {reward_id: reward_id, prize_code: unique_id}.to_json
      
      iw = Instantwin.create(
        valid_from: wintime,
        valid_to: wintime_end,
        won: false,
        instantwin_interaction_id: iw_interaction.id,
        reward_info: reward_info
      )
      hash_counter += 1
      cdate += 1
    end
  end
  
  def get_instantwin_reward(prizes)
    prize_id = prizes[0]
    prizes.delete_at(0)
    prize_id
  end
  
  #
  # Returns days in a month
  #
  # month - month want to know days amount
  # year - specific year
  # 
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

end
