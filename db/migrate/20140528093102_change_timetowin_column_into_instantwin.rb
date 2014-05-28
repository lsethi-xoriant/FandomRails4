class ChangeTimetowinColumnIntoInstantwin < ActiveRecord::Migration
  def change
    rename_column :instantwins, :time_to_win, :time_to_win_start
  end
end
