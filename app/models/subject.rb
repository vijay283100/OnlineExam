class Subject < ActiveRecord::Base
  
  validates_uniqueness_of :name, :scope => [:organization_id], :case_sensitive => false, :message=>"Sorry"
  
  has_and_belongs_to_many :users
  has_many :questions
  has_many :categories, :through => :categorysubject
  has_many :categorysubject

  has_many :subjectuser
  has_many :users, :through => :subjectuser
  
  before_validation :strip_whitespace, :only => [:name]

  
  def getuser(u,s)
    
    subjectUser = Subjectuser.find_by_user_id_and_subject_id(u,s)
    if subjectUser
    return true
    else
      return false
    end
  end
  
 def strip_whitespace
  self.name = self.name.strip
 end

  
  
end
