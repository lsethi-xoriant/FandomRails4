class AddIndexInRewardInfoPrizeCodeForInstantwin < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_instantwins_on_reward_info_prize_code ON instantwins ((reward_info->>'prize_code'))")
  end

  def down
    execute("DROP INDEX index_instantwins_on_reward_info_prize_code")
  end
end
