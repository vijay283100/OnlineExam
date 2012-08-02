class CategoryTitlesController < ApplicationController
  filter_access_to :all
  def index
    @collect_type = params[:type]
    @organization_id = Setting.find(:first).organization_id
    @category_types = CategoryType.find_all_by_organization_id(@organization_id.to_i)

    if @collect_type == '1' 
      @orgLevels = Course.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.class')
    end
    
    if @collect_type == '3'
      @orgLevels = Course.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.course')
    end

   if @collect_type == '4' 
      @orgLevels = AcademicYear.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.year')
    end
    
    if @collect_type == '2'
      @orgLevels = Section.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.section')
    end

    if @collect_type == '5' or @collect_type == '7' 
      @orgLevels = Department.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.dept')
    end  
    
    if @collect_type == '8'
      @orgLevels = Department.where(['organization_id = ?',@organization_id]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)
      @name = t('org.domain')
    end
    
    if @collect_type == '6'
      @orgLevels = Semester.where(['organization_id = ?',@organization_id]).paginate(:page => params[:page], :per_page => 5)
      @name = t('org.semester')
    end
  end
  
  def new
    @collect_type = params[:type]
    @organization_id = Setting.find(:first).organization_id

    @category_title = CategoryTitle.new
    @category_title_names = CategoryTitle.where(["category_type_id = ?", @collect_type]) 
    
    @category_type = CategoryType.find(params[:type].to_i)
    if @category_type.id == 1
    @name = t('org.class')
    elsif @category_type.id == 2
    @name = t('org.section')
    elsif @category_type.id == 3
    @name = t('org.course')
    elsif @category_type.id == 4
    @name = t('org.year')
    elsif @category_type.id == 5
    @name = t('org.dept')
    elsif @category_type.id == 6
    @name = t('org.semester')
    elsif @category_type.id == 7
    @name = t('org.dept')
    elsif @category_type.id == 8
    @name = t('org.domain')
    else
    @name = @category_type.title.capitalize
    end
  end
  
  def create
    @organization_id = Setting.find(:first).organization_id
    @collect_title = params[:name]
    @category_type_id = params[:c_id]

    if @category_type_id == "1" 
      course = Course.new(:name=>@collect_title, :organization_id => @organization_id)
      if course.save
        flash[:success] = t('flash_success.class_created')
      else
        flash[:notice] = t('flash_notice.class_cant')
      end
    end
    
    if @category_type_id == "3" 
      course = Course.new(:name=>@collect_title, :organization_id => @organization_id)
      if course.save
        flash[:success] = t('flash_success.course_created')
      else
        flash[:notice] = t('flash_notice.course_cant')
      end
    end
    
    if @category_type_id == "4"
      academicYear = AcademicYear.new(:name=>@collect_title, :organization_id => @organization_id)
      if academicYear.save
        flash[:success] = t('flash_success.year_created')
      else
        flash[:notice] = t('flash_notice.year_cant')
      end
    end
    
    if @category_type_id == "2" 
      section = Section.new(:name=>@collect_title, :organization_id => @organization_id)
      if section.save
        flash[:success] = t('flash_success.section_created')
      else
        flash[:notice] = t('flash_notice.section_cant')
      end
    end   
 
    if @category_type_id == "6" 
      semester = Semester.new(:name=>@collect_title, :organization_id => @organization_id)
      if semester.save
        flash[:success] = t('flash_success.semester_created')
      else
        flash[:notice] = t('flash_notice.semester_cant')
      end
    end   
    
    if @category_type_id == "5" or @category_type_id == "7"
      department = Department.new(:name=>@collect_title, :organization_id => @organization_id)
      if department.save
        flash[:success] = t('flash_success.department_created')
      else
        flash[:notice] = t('flash_notice.department_cant')
      end
    end
    
    if @category_type_id == "8"
      department = Department.new(:name=>@collect_title, :organization_id => @organization_id)
      if department.save
        flash[:success] = t('flash_success.domain_created')
      else
        flash[:notice] = t('flash_notice.domain_cant')
      end
    end
    
    redirect_to :action=>"index", :controller=>"category_titles", :type=>@category_type_id.to_i
  end

  def editCourse
    @course = Course.find(params[:id])
  end

    def updateCategory
      @category_id= params[:category_id]
      @categoryType = params[:categoryType]
      @categoryName = params[:categoryName]
      
      if @categoryType == "1" or @categoryType == "3"
        @course = Course.find_by_id(@category_id)
        if @course.update_attributes(:name => @categoryName)
          render :json => {:text=>true}
        else
          render :json => {:notUpdated=>true}
        end
      end
      
      if @categoryType == "4" 
        @academicYear = AcademicYear.find_by_id(@category_id)
        if @academicYear.update_attributes(:name => @categoryName)
          render :json => {:text=>true}
        else
          render :json => {:notUpdated=>true}
        end    
      end

      if @categoryType == "2" 
        @section = Section.find_by_id(@category_id)
        if @section.update_attributes(:name => @categoryName)
          render :json => {:text=>true}
        else
          render :json => {:notUpdated=>true}
        end
      end
      
      if @categoryType == "6" 
        @semester = Semester.find_by_id(@category_id)
        if @semester.update_attributes(:name => @categoryName)
          render :json => {:text=>true}
        else
          render :json => {:notUpdated=>true}
        end
      end
      
      if @categoryType == "5" or @categoryType == "7" or @categoryType == "8"
        @department = Department.find_by_id(@category_id)
        if @department.update_attributes(:name => @categoryName)
          render :json => {:text=>true}
        else
          render :json => {:notUpdated=>true}
        end
      end

    end

    def deleteCategory
      @category_id= params[:category_id]
      @categoryType = params[:categoryType]
      
      if @categoryType == "1" or @categoryType == "3"
        categories = Category.where(["course_id = ?", @category_id])
        if categories.empty?
          @course = Course.find_by_id(@category_id)
          @course.destroy
          render :text => true
        else
          render :text => false
        end
      end
      
      if @categoryType == "4"
        categories = Category.where(["academic_year_id = ?", @category_id])
        if categories.empty?
        @academicYear = AcademicYear.find_by_id(@category_id)
        @academicYear.destroy
          render :text => true
        else
          render :text => false
        end
      end

      if @categoryType == "2" 
        categories = Category.where(["section_id = ?", @category_id])
        if categories.empty?
        @section = Section.find_by_id(@category_id)
        @section.destroy
          render :text => true
        else
          render :text => false
        end
      end
      
      if @categoryType == "6" 
        categories = Category.where(["semester_id = ?", @category_id])
        if categories.empty?
        @semester = Semester.find_by_id(@category_id)
        @semester.destroy
          render :text => true
        else
          render :text => false
        end
      end
      
      if @categoryType == "5" or @categoryType == "7" or @categoryType == "8"
        categories = Category.where(["department_id = ?", @category_id])
        if categories.empty?
        @department = Department.find_by_id(@category_id)
        @department.destroy
          render :text => true
        else
          render :text => false
        end
      end
    end

  
end
