class HomeController < ApplicationController
   
  def index
    if t('language.lang') == "en"
      @aboutus = Aboutus.find_by_locale_id(1)
    elsif t('language.lang') == "de"
      @aboutus = Aboutus.find_by_locale_id(2)
    end
  end
  
  def view_aboutus
        @aboutus_english = Aboutus.find_by_locale_id(1)
        @aboutus_german = Aboutus.find_by_locale_id(2)
  end
  
  def view_clients
    @clients = Clientinfo.order('created_at desc')
  end
  
  def view_features
    
  end
  
  def veiw_modules
    
  end
  
  def view_contactus
    
  end
 
end
