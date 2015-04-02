class Download < ActiveRecord::Base
  attr_accessible :title, :attachment, :ical_fields, :type, :ical_start, :ical_end
  attr_accessor :type, :ical_start, :ical_end

  has_attached_file :attachment
  
  has_one :interaction, as: :resource

  validates_presence_of :attachment, unless: Proc.new { |c| ical_fields }
  before_validation :set_ical_fields

  def one_shot
    false
  end

  def set_ical_fields
    if ical_start.present? and ical_end.present?
      ical_value = { 
        "start_datetime" => { 
          "type" => "date", "value" => ical_start 
        }, 
        "end_datetime" => { 
          "type" => "date", "value" => ical_end 
        } 
      }
      ical_start = nil
      ical_end = nil
      attachment.destroy()
    else
      ical_value = {}
    end
    write_attribute :ical_fields, ical_value.to_json
  end
end
