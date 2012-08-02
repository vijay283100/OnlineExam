class Image < ActiveRecord::Base
  
  has_attached_file :photo,
     :styles => {       
      }
  
  has_many :questions
  has_many :answers
end
