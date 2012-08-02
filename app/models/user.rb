class User < ActiveRecord::Base

       acts_as_authentic do |c|
       c.require_password_confirmation = false
       c.validate_password_field = false
       end


  has_many :shared_question
  has_many :questions, :through => :shared_question

  has_one :categoryuser
  has_one :category, :through => :categoryuser

  belongs_to :role 
  
  has_and_belongs_to_many :subjects
  has_many :evaluations
  has_many :exam_results
  has_many :questions
  has_one :feedback
  has_many :reports
  
  
  has_many :categories
  has_many :categories, :through => :categoryuser
  
  has_many :subjectuser
  has_many :subjects, :through => :subjectuser
  
  has_many :subjectuser
  has_many :categorysubjects, :through => :subjectuser

  has_many :evaluate_exams
  has_many :exams, :through=> :evaluate_exams

  def self.find_by_login_or_email(login)
   find_by_login(login) || find_by_email(login)
  end

  def role_symbols  
   @role = []
   @role << role.name.underscore.to_sym
  end

  def self.search(search,role)
    if search
      where(['login LIKE ? and role_id = ?', "%#{search}%",role])
    end
  end

  def self.search_user(search) 
  if search
    where('login LIKE ?', "%#{search}%")    
  end
  end



end
