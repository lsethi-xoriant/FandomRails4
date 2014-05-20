class CreateRegistrationTable < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :title
      t.timestamps
    end
  end
end