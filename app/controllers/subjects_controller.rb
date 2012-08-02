class SubjectsController < ApplicationController
  filter_access_to :all
  
  def index
    @organization_id = Setting.find(:first).organization_id
    @subjects = Subject.where(['organization_id = ?',@organization_id]).order('created_at desc').paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @organization_id = Setting.find(:first).organization_id
    @subject = Subject.new
    @categories = Category.where(["organization_id=?", @organization_id.to_i])
  end

  def create
    @organization_id = Setting.find(:first).organization_id
    @subject = Subject.new(params[:subject])
    @category_id = params[:subject][:id].to_i
    @category = Category.find(@category_id)  
    @subject.categories << @category
    @subject.organization_id = @organization_id
     if @subject.save
          flash[:success] = t('flash_success.subject_created')
        else
          flash[:notice] = t('flash_notice.subject_exists')
      end
     redirect_to :action=>"index", :controller=>"subjects"
  end

  def add_subject_category
    @setting = Setting.find(1)
    @organization_id = @setting.organization_id
    
    @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i]).sort { |x,y| x.sort_order <=> y.sort_order }
     unless @category_types.empty?
       @last_id = @category_types.last.id
        @first_id = @category_types.first.id
     end
    @categories = Category.where(["organization_id = ?", @organization_id])
    @subjects = Subject.where(['organization_id = ?',@organization_id]).order('created_at desc')
  end

  def cs
    @subject = Subject.find_by_id(params[:subject].to_i)
    @category = Category.find_by_id(params[:id].to_i)
     @subject.categories << @category
       
     @subject.save
      flash[:success] = t('flash_success.subject_to_cat')
      redirect_to :action=>"index", :controller=>"subjects"
     rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      flash[:notice] = t('flash_notice.sub_to_cat_exists')
      redirect_to :action=>"index", :controller=>"subjects"
  end

  def edit
    @subject = Subject.find(params[:id]) 
  end

  def update
    @subject = Subject.find(params[:id])
    @subject.name = params[:subject][:name]
    if @subject.save
      flash[:success] = t('flash_success.subject_updated')
    else
      flash[:notice] = t('flash_notice.subject_update_exists')
    end
    redirect_to :action=>"index", :controller=>"subjects"
  end

  def destroy
    @subject = Subject.find(params[:id])
    @category = @subject.categories
    
    questions = Question.find(:all, :joins => :categorysubject,
    :conditions => { :categorysubjects => { :subject_id => @subject.id } })
    
    if questions.empty?
     if @category
        @subject.categories.delete(@category)
     end
     @subject.destroy 
     flash[:success] = t('flash_success.subject_deleted')
     redirect_to :back
    else
     flash[:notice] = t('flash_notice.cant_del_sub')
     redirect_to :back 
    end
  end

end
