class Promocode < ActiveRecord::Base
  	attr_accessible :title, :code

  	before_create :generate_code

  	validates_presence_of :title
  	validates_uniqueness_of :code
  
  	has_one :interaction, as: :resource

  	def generate_code
	    begin
	    	self.code = SecureRandom.hex(12)
	    end while Promocode.find_by_code(self.code)
  	end
end
  


  