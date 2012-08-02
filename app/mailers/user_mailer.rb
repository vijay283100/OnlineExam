class UserMailer < ActionMailer::Base

  default :from => "from@example.com"
  @@host_name = Setting.find(:first).url
   def user_creation_confirmation(user,pwd)  
     @@user_name = user.name 
     @@user_login = user.login
     @@user_password = pwd
     
     @email_value = Email::Email_Template_List['user_creation']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
      @email_content = @email_template.content
     elsif t('language.lang') == "de"
      @email_content = @email_template.content_de
     end
     @email_content = @email_content.gsub("$^_username_^$",@@user_name).gsub("$^_userlogin_^$",@@user_login).gsub("$^_userpassword_^$",@@user_password)
     
     mail(:to => user.email, :subject => t('email.registered'))  
   end

   def send_reset_password(user)
     @@user_name = user.name 
     @host_name = Setting.find(:first).url
     @email_value = Email::Email_Template_List['Forgot-Password']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
     @email_content = @email_template.content
     elsif t('language.lang') == "de"
     @email_content = @email_template.content_de
     end
     @edit_password_reset_url = edit_password_reset_url(user.perishable_token, :host => @host_name)
     @email_content = @email_content.gsub("$^_username_^$",@@user_name)#.gsub("$^_reset_url_^$",@edit_password_reset_url)
     mail(:to => user.email, :subject => t('email.reset_password'))
   end

   def user_registered_confirmation(user)  
    
     @@user_name = user.name
     
     @email_value = Email::Email_Template_List['Examinee-Registration']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
      @email_content = @email_template.content
     elsif t('language.lang') == "de"
      @email_content = @email_template.content_de
     end
     @email_content = @email_content.gsub("$^_username_^$",@@user_name)
     #@user = user
     mail(:to => user.email, :subject => t('email.registered'))  
   end  

   
   def user_registration_email_confirmation(user,pwd)
     @@user_name = user.name
     @@user_password = pwd
     @@user_login = user.login
     @host_name = Setting.find(:first).url
     @email_value = Email::Email_Template_List['Examinee-Registration-Confirmation']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
       @email_content = @email_template.content
     elsif t('language.lang') == "de"
       @email_content = @email_template.content_de
     end
     @confirm_email_user_registration_url = confirmEmail_password_reset_url(user.perishable_token, :host => @host_name)
     @email_content = @email_content.gsub("$^_username_^$",@@user_name).gsub("$^_userlogin_^$",@@user_login)#.gsub("$^_userpassword_^$",@@user_password)
     mail(:to => user.email, :subject => t('email.verify_email'))
   end
   
   def examinee_registration_confirmation(user)  
     @@user_name = user.name 
     
     @email_value = Email::Email_Template_List['registration_confirmation']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
       @email_content = @email_template.content
     elsif t('language.lang') == "de"
       @email_content = @email_template.content_de
     end
     @email_content = @email_content.gsub("$^_username_^$",@@user_name)

     mail(:to => user.email, :subject => t('email.account_activated'))  
   end
   
   def examinee_registration_rejection(user)  
     
     @@user_name = user.name 
     
     @email_value = Email::Email_Template_List['Examinee-Account-Rejection']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
       @email_content = @email_template.content
     elsif t('language.lang') == "de"
       @email_content = @email_template.content_de
     end
     @email_content = @email_content.gsub("$^_username_^$",@@user_name)
     mail(:to => user.email, :subject => t('email.account_rejected'))  
   end

  
  def export_csv(outfile,csv_data,current_user)  
     
  @current_user_email_id = current_user.email
  @@user_name = current_user.name    
     @email_value = Email::Email_Template_List['temporary_examinee_creation']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
       @email_content = @email_template.content
     elsif t('language.lang') == "de"
       @email_content = @email_template.content_de
     end
     @outfile = outfile  
      attachments[@outfile]=csv_data
      @email_content = @email_content.gsub("$^_username_^$",@@user_name)
      mail(:to => @current_user_email_id, :subject => t('email.temp_examinee_list'))  
  end

  
  def user_set_password(user)
     @@user_name = user.name 
     @@user_login = user.login
     @host_name = Setting.find(:first).url
     @email_value = Email::Email_Template_List['User-Creation']
     @email_template = Email.find_by_section_id(@email_value)
     if t('language.lang') == "en"
       @email_content = @email_template.content
     elsif t('language.lang') == "de"
       @email_content = @email_template.content_de
     end     
     @email_content = @email_content.gsub("$^_username_^$",@@user_name).gsub("$^_userlogin_^$",@@user_login)
     @set_password = varifyPassword_password_reset_url(user.perishable_token, :host => @host_name)
     mail(:to => user.email, :subject => t('email.welcome'))  
  end

  def examSchedule(exam,user)
    @examinee_name = user.name
    @examName = exam.name
    @examCode = exam.exam_code
    @examDate = exam.exam_date.strftime('%m/%d/%Y')
    @examTime = exam.exam_date.strftime('%I:%M %p')
    @examDuration_hr = exam.total_time.hour().to_s
    @examDuration_min = exam.total_time.min().to_s
    @examDuration = @examDuration_hr + ":" + @examDuration_min + " hrs "
    
    @email_value = Email::Email_Template_List['Exam-schedule']
    @email_template = Email.find_by_section_id(@email_value)
    if t('language.lang') == "en"
      @email_content = @email_template.content
    elsif t('language.lang') == "de"
      @email_content = @email_template.content_de
    end
    @email_content = @email_content.gsub("$^_username_^$",@examinee_name).gsub("$^_examname_^$",@examName).gsub("$^_examcode_^$",@examCode).gsub("$^_examdate_^$",@examDate).gsub("$^_examtime_^$",@examTime).gsub("$^_examduration_^$",@examDuration)
    mail(:to => user.email, :subject => t('email.exam_schedule'))
  end
  
 end
