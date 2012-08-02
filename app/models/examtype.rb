class Examtype < ActiveRecord::Base
  has_many :categoryexams
  validates_uniqueness_of :name, :scope => [:organization_id], :case_sensitive => false
  
  before_validation :strip_whitespace, :only => [:name]
  
 def strip_whitespace
  self.name = self.name.strip
 end
  
end
