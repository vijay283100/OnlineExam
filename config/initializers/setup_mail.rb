ActionMailer::Base.delivery_method=:smtp
ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "gmail.com",
  :authentication => :login,
  :user_name => "pitsvirtualx",
  :password => "pits@123",
  :enable_starttls_auto => true
}
ActionMailer::Base.perform_deliveries = true 
ActionMailer::Base.raise_delivery_errors = true 
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.default_content_type = "text/html"

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?  
