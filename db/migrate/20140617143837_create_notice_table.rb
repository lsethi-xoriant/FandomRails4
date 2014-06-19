class CreateNoticeTable < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.references :user
      t.text :html_notice
      t.datetime :last_sent
      t.boolean :viewd
      t.boolean :read
      t.timestamps
    end
  end
end
