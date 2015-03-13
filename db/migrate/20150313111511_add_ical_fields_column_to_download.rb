class AddIcalFieldsColumnToDownload < ActiveRecord::Migration
  def change
    add_column :downloads, :ical_fields, :json
  end
end
