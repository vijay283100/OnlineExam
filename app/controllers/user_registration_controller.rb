class UserRegistrationController < ApplicationController
  
  def index
    redirect_to :action => :new
  end
  
  def new
    @user = User.new       
  end

  def create
    @user = User.new(params[:user])
    
    $pwd = params[:password]
    @setting = Setting.find(:first)
    @user.email = params[:email]
    @user.password = params[:password]
    @user.is_registered = 1
    if @user.save
      if @setting.examineeApprove == 1
        UserMailer.user_registered_confirmation(@user).deliver
        flash[:success] = t('flash_success.registered_appr')
      else
        UserMailer.user_registration_email_confirmation(@user,$pwd).deliver
        flash[:success] = t('flash_success.registered_verify')
      end

      redirect_to :action=>:index, :controller=>:home
    else
      flash[:notice] = t('flash_notice.not_reg')
      redirect_to :action => :new  
    end
  end
  
   def confirm_email
    flash[:success] = t('flash_success.account_activated')
    redirect_to login_path  
   end
  
end
