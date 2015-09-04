class ContestIdentityCollectionUser
  include ActiveAttr::Attributes
  include ActiveAttr::Model

  attribute :first_name, type: String
  attribute :last_name, type: String
  attribute :receipt_number, type: String
  attribute :receipt_amount, type: String
  attribute :product_code, type: String
  attribute :newsletter, type: String

  attribute :minute_of_emission, type: String
  attribute :hour_of_emission, type: String

  attribute :day_of_emission, type: String
  attribute :month_of_emission, type: String
  attribute :year_of_emission, type: String
  
  attribute :day_of_birth, type: String 
  attribute :month_of_birth, type: String
  attribute :year_of_birth, type: String

  validates_presence_of :first_name, :last_name, :receipt_number, :product_code, :receipt_amount
  validate :date_of_emission_present?
  validate :time_of_emission_present?
  validate :adult?

  def adult?
    if year_of_birth.blank? || month_of_birth.blank? || day_of_birth.blank?
      errors.add(:birth_date, "non può essere lasciata in bianco")
    else
      contest_start_date = Time.parse(CONTEST_IDENTITY_COLLECTION_START_DATE)
      birth_date = Time.parse("#{year_of_birth}/#{month_of_birth}/#{day_of_birth}")
      if (contest_start_date < birth_date + 18.year)
        errors.add(:base, "All'inizio del concorso (15 settembre 2015) devi avere compiuto 18 anni")
      end
    end
  end

  def date_of_emission_present?
    if day_of_emission.blank? || month_of_emission.blank? || year_of_emission.blank?
      errors.add(:date_of_emission, "non può essere lasciata in bianco")
    end
  end  

  def time_of_emission_present?
    if minute_of_emission.blank? || hour_of_emission.blank?
      errors.add(:time_of_emission, "non può essere lasciata in bianco")
    end
  end  

end