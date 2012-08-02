class CategoriesController < ApplicationController
  filter_access_to :all
  def index
    @organization_id = Setting.find(:first).organization_id
    @category = Category.new
    if @organization_id == 1
      @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i])
      @courses = Course.where(["organization_id=?", @organization_id.to_i])
      @sections = Section.where(["organization_id=?", @organization_id.to_i])
    end
    
    if @organization_id == 2
      @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i])
      @courses = Course.where(["organization_id=?", @organization_id.to_i])
      @academicYears = AcademicYear.where(["organization_id=?", @organization_id.to_i])
      @departments = Department.where(["organization_id=?", @organization_id.to_i])
      @semesters = Semester.where(["organization_id=?", @organization_id.to_i])
    end

    if @organization_id == 3
      @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i])
      @departments = Department.where(["organization_id=?", @organization_id.to_i])
    end

    if @organization_id == 4
      @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i])
      @departments = Department.where(["organization_id=?", @organization_id.to_i])
    end    
    
  end
  
  def create

    @organization_id = Setting.find(:first).organization_id
    @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i])    

    if @organization_id == 1
      category = Category.new
      category.course_id = params[:courseName]
      category.academic_year_id = params[:academicYear]
      category.section_id = params[:section]
      category.organization_id = @organization_id
      if category.save
        flash[:success] = t('flash_success.category_created')
      else
        flash[:notice] = t('flash_notice.category_exists')
      end
    end

    if @organization_id == 2
      category = Category.new
      category.course_id = params[:courseName]
      category.academic_year_id = params[:academicYear]
      category.department_id = params[:department]
      category.semester_id = params[:semester]
      category.organization_id = @organization_id
      if category.save
        flash[:success] = t('flash_success.category_created')
      else
        flash[:notice] = t('flash_notice.category_exists')
      end
    end
    
    if @organization_id == 3
      category = Category.new
      category.academic_year_id = params[:academicYear]
      category.department_id = params[:department]
      category.organization_id = @organization_id
      if category.save
        flash[:success] = t('flash_success.category_created')
      else
        flash[:notice] = t('flash_notice.category_exists')
      end
    end
    
    if @organization_id == 4
      category = Category.new
      category.academic_year_id = params[:academicYear]
      category.department_id = params[:department]
      category.organization_id = @organization_id
      if category.save
        flash[:success] = t('flash_success.category_created')
      else
        flash[:notice] = t('flash_notice.category_exists')
      end
    end
    redirect_to :back
  end
  
  def listCategories
    @organization_id = Setting.find(:first).organization_id
    @categories = Category.where(["organization_id=?", @organization_id.to_i]).paginate(:page => params[:page], :per_page => 10)
  end
  
  def delete_category
    category = Category.find_by_id(params[:category_id].to_i)
    categorexam = Categoryexam.where(["category_id = ?", params[:category_id].to_i])
    categoruser = Categoryuser.where(["category_id = ?", params[:category_id].to_i])
    categorsubject = Categorysubject.where(["category_id = ?", params[:category_id].to_i])

    if categorexam.empty? and categoruser.empty? and categorsubject.empty?
      if category.destroy
       flash[:success] = t('flash_success.category_deleted')
      end
    else
       flash[:notice] = t('flash_notice.category_cant')
    end
    redirect_to :back
  end
end
