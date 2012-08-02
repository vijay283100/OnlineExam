class Clientinfo < ActiveRecord::Base
  validates_uniqueness_of :name, :case_sensitive => false
   before_validation :strip_whitespace, :only => [:name]
  
  def strip_whitespace
   self.name = self.name.strip
  end 
end
