class ChangeRewardIdColumnNameToCurrencyIdForInstantwinInteractions < ActiveRecord::Migration
  def change
    rename_column :instantwin_interactions, :reward_id, :currency_id
  end
end
