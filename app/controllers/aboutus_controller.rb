class AboutusController < ApplicationController
  filter_access_to :all
  def index
        @aboutus_english = Aboutus.find_by_locale_id(1)
        @aboutus_french = Aboutus.find_by_locale_id(2)

  end
  
  def create
        @aboutus_english = Aboutus.find_by_locale_id(1)
        @aboutus_french = Aboutus.find_by_locale_id(2)

    @aboutus_english.description = params[:content_english]
    @aboutus_french.description = params[:content_french]
    if @aboutus_english.save and @aboutus_french.save
      flash[:success] = t('flash_success.about_us')  
      redirect_to :action=>"index"
    end
  end

end


