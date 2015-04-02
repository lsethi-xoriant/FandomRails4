class Download < ActiveRecord::Base
  attr_accessible :title, :attachment, :ical_fields, :type, :ical_start, :ical_end, :ical_location
  attr_accessor :type, :ical_start, :ical_end, :ical_location

  has_attached_file :attachment
  
  has_one :interaction, as: :resource

  validates_presence_of :attachment, unless: Proc.new { |c| ical_fields }
  before_validation :set_ical_fields

  def one_shot
    false
  end

  def set_ical_fields
    if ical_start.present? or ical_end.present? or ical_location.present?
      ical_value = { 
        "start_datetime" => { 
          "type" => "date", "value" => ical_start 
        }, 
        "end_datetime" => { 
          "type" => "date", "value" => ical_end 
        },
        "location" => ical_location
      }
      ical_start = nil
      ical_end = nil
      ical_location = nil
      attachment.destroy()
    else
      ical_value = {}
    end
    write_attribute :ical_fields, ical_value.to_json
  end
end
