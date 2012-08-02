class WelcomeController < ApplicationController
  filter_access_to :all
  #layout "home"
  def index
  end

  def admin_dashboard
    @setting = Setting.find(:first)
    @pageCollect = params[:pageLength].to_i
    if @pageCollect == 0
      @pagelength = 10
    else
      @pagelength = params[:pageLength].to_i
    end
    if params[:char]
      letter = params[:char]
      @letter = params[:char]
      @registered_examinees = User.where(["is_registered = ? and role_id = ? and is_temp_examinee = ? and name like '#{params[:char]}%'", 1,Examinee,0]).paginate(:page => params[:page], :per_page => @pagelength)
    else
      @registered_examinees = User.where(["is_registered = ?",1]).paginate(:page => params[:page], :per_page => @pagelength)
    end
  end
  
  def examiner_dashboard
    
  end
  
  def qsetter_dashboard
    
  end
  
  def examinee_dashboard
    
  end
  
  def confirm_registration
    @all_approved_users = params[:check_examinee]
    @all_approved_users.each do|approved|
      @user = User.find_by_id(approved.to_i)
      @user.update_attributes(:is_approved => 1)
      if (@user.is_approved == 0 and @user.confirmed == false) or (@user.is_approved == 1 and @user.confirmed == false) or (@user.is_approved == 2 and @user.confirmed == false)
       UserMailer.user_registration_email_confirmation(@user,$pwd).deliver
      end
    end
     flash[:success] = t('flash_success.email_verification')
      respond_to do |format|
        format.html { redirect_to :back }
         format.js
      end
  end
  
  def reject_registration
    @rejected_users = params[:check_examinee]
    @rejected_users.each do|rejected|
      @user = User.find_by_id(rejected.to_i)
      unless (@user.is_approved == 2 and @user.confirmed == false)
      @user.update_attributes(:confirmed => false,:is_approved => 2)
      UserMailer.examinee_registration_rejection(@user).deliver
      end
    end
     flash[:success] = t('flash_success.email_rejection')
      respond_to do |format|
        format.html { redirect_to :back }
         format.js
      end
    
  end
  
end
