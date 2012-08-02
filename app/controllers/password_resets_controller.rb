class PasswordResetsController < ApplicationController
 before_filter :require_no_user
 before_filter :load_user_using_perishable_token, :only => [:edit, :update]
   before_filter :load_user_using_perishable_token_email,:only=>:confirmEmail

 def index
   redirect_to :action => :new
 end

 def new
  render  
 end
  
 def create  
  @user = User.find_by_email(params[:email])  
  if @user  
    UserMailer.send_reset_password(@user).deliver
    flash[:success] = t('flash_success.reset_password')  
    redirect_to root_url  
  else  
  flash[:notice] = t('flash_notice.no_user_with_email')    
  redirect_to :action => :new  
  end  
 end

  def edit  
    render  
  end  
  
 def update  
   @user.password = params[:password]
  if @user.save  
    flash[:success] = t('flash_success.password_updated')  
    redirect_to root_url  
  else  
  render :action => :edit  
  end  
 end  


  def confirmEmail
    flash[:success] = t('flash_success.account_activated') 
    redirect_to login_path 
  end

  def varifyPassword
    @user = User.find_by_perishable_token(params[:id])
    unless @user == nil
      render :action => "setPassword"
    else
      flash[:notice] = t('flash_notice.account_verified') 
      redirect_to :action=>"new", :controller=>"user_sessions"
    end
  end

  def setPassword
    @user = User.find_by_perishable_token(params[:id])
  end
  
  def savePassword
    @user_id = params[:user_id]
    @user = User.find(params[:user_id])
    @user.password = params[:password]
    @user.confirmed = 1
    @user.active = 1
    @user.save
    redirect_to root_url
  end

  private  
    def load_user_using_perishable_token  
      @token = params[:id]
      @user = User.find_by_perishable_token(params[:id])  
      unless @user  
        flash[:notice] = t('password_reset.cant_locate')  
        redirect_to root_url  
      end  
  end
  
    def load_user_using_perishable_token_email
      @user = User.find_using_perishable_token(params[:id])
      if @user
      @user.confirmed=true
      @user.is_approved = 1
      @user.active = 1
      @user.save
      end
      unless @user
        flash[:notice] = t('flash_notice.url_expired')
        redirect_to root_url
      end
    end
  
end
