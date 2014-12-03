class ChangeColumnNewsletterDefaultToUser < ActiveRecord::Migration
  def change
    change_column_default(:users, :newsletter, nil)
  end
end
