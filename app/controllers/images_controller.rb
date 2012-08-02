class ImagesController < ApplicationController
  filter_access_to :all
  def index
    @images = Image.find(:all)
  end

  def new
    @image = Image.new
  end
  
  def create
    @image = Image.new(params[:image])
    if @image.save
      flash[:success] = t('flash_success.image_uploaded')
    end
    redirect_to :back
  end
  
  def clientImage
    @image = Image.new
  end
  
  def createClientimage
   unless params[:image] == nil
      clientImage = ClientImage.find(:first)
      unless clientImage == nil
        clientImage.destroy
      end
        @image = ClientImage.new(params[:image])        
          if @image.save
            flash[:success] = t('flash_success.image_uploaded')
            redirect_to :back
          else
            flash[:notice] = t('flash_notice.must_be_url')
            redirect_to :back
        end
    else
            flash[:notice] = t('flash_notice.image_cant')
            redirect_to :back
   end     
  end

end
