class ClientinfoController < ApplicationController
  filter_access_to :all
  def index
        @clientinfo = Clientinfo.find(:all)
  end
  
    def new
      @clientinfo = Clientinfo.new
    end
    
    def create
    @clientinfo = Clientinfo.new(params[:clientinfo])
      if @clientinfo.save
                flash[:success] = t('flash_success.client_added')
                redirect_to :action=>:index, :controller=>:clientinfo
      else
                flash[:notice] = t('flash_notice.client_exists')
                redirect_to :action=>:index, :controller=>:clientinfo
      end
    end
      def edit
        @clientinfo = Clientinfo.find_by_id(params[:id])
      end
      
        def update
          @clientinfo = Clientinfo.find_by_id(params[:id])
          if @clientinfo.update_attributes(params[:clientinfo])
           flash[:success] = t('flash_success.client_updated')
           redirect_to :action=>:index, :controller=>:clientinfo
          else
               flash[:notice] = t('flash_notice.client_exists')
               redirect_to :action=>:index, :controller=>:clientinfo           
          end
        end
        
          def destroy
            @clientinfo = Clientinfo.find(params[:id])
            if @clientinfo.destroy
              flash[:success] = t('flash_success.client_deleted')
              redirect_to :back
            end
          end
        

end


