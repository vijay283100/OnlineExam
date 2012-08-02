class ApplicationController < ActionController::Base
  
  
 def permission_denied  
   flash[:notice] = t('flash_notice.app_no_access')    
   redirect_to root_url  
 end
  helper :all  
  protect_from_forgery
  #before_filter { |c| Authorization.current_user = c.current_user } 
  helper_method :current_user_session, :current_user
  
  $setting = Setting.find(:first)
  
  before_filter :set_locale
    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        cookies['locale'] = { :value => params[:locale], :expires => 1.year.from_now }
        I18n.locale = params[:locale].to_sym
      elsif cookies['locale'] && I18n.available_locales.include?(cookies['locale'].to_sym)
        I18n.locale = cookies['locale'].to_sym
      end
    end
 
  private
    def current_user_session
      logger.debug "ApplicationController::current_user_session"
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
 
    def current_user
      logger.debug "ApplicationController::current_user"
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
 
    def require_user
      logger.debug "ApplicationController::require_user"
      unless current_user
        store_location
        flash[:notice] = t('flash_notice.login_access')   
        redirect_to new_user_session_url
        return false
      end
    end
 
    def require_no_user
      logger.debug "ApplicationController::require_no_user"
      if current_user
        store_location
        flash[:notice] = t('flash_notice.logout_access')
        redirect_to account_url
        return false
      end
    end
 
    def store_location
      session[:return_to] = request.request_uri
    end
 
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
