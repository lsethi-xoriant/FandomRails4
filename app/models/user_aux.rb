class UserAux < ActiveModelWithJSON
  attr_accessor :contest, :terms
  
  validate :contest_presence
  validate :terms_presence

  def contest_presence
    errors.add("Concorso", "deve essere accettato") unless @attributes["contest"] == "true"
  end

  def terms_presence
    errors.add("Regolamento", "deve essere accettato") unless @attributes["terms"] == "true"
  end
end