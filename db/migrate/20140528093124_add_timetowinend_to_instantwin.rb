class AddTimetowinendToInstantwin < ActiveRecord::Migration
  def change
    add_column :instantwins, :time_to_win_end, :datetime
  end
end
