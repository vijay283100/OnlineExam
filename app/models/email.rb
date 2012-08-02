class Email < ActiveRecord::Base
    
  Email_Template_List = {
  'Examinee-Registration'=>"t1",
  'Examinee-Registration-Confirmation'=>"t2",
  'Examinee-Account-Rejection'=>"t3", 
  'User-Creation'=>"t4", 
  'Forgot-Password'=>"t5", 
  'temporary_examinee_creation'=>"t6", 
  #'user_registration_email_confirmation'=>"t7",
  'Exam-schedule'=>"t8"
  }      
  
end
