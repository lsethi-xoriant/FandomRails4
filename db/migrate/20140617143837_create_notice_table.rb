class CreateNoticeTable < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.references :user
      t.text :html_notice
      t.datetime :last_sent
      t.boolean :viewed, :default => false
      t.boolean :read, :default => false
      t.timestamps
    end
  end
end
