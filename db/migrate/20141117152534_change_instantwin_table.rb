class ChangeInstantwinTable < ActiveRecord::Migration
  def change
    remove_column :instantwins, :contest_periodicity_id
    remove_column :instantwins, :title
    rename_column :instantwins, :time_to_win_start, :valid_from
    rename_column :instantwins, :time_to_win_end, :valid_to
  end
end
