class Categoryuser < ActiveRecord::Base
  
  validates_uniqueness_of :currentyear, :scope => [:category_id, :user_id], :message=>"Already exists"
  belongs_to :user
  belongs_to :category
  
  has_many :categoryexamuser
  has_many :categoryexams, :through => :categoryexamuser
  
  has_many :users
  has_many :users, :through => :categoryuser

  
      def gathercat_user(g)
      
      p = Category.find_by_id(g.category_id)
      @organization_id = Setting.find(:first).organization_id   
      
   if @organization_id == 1
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     section = Section.find_by_id_and_organization_id(p.section_id,@organization_id)    
     @group = course.name[0..40] + " << " + section.name[0..20] + "Section" 
   end
   
   if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semester_id,@organization_id)
     
     @group = course.name[0..25] + " << " + academicYear.name[0..35] + " year " + " << " + department.name[0..8] + " << " + semester.name[0..8] + " semester " 
   end
 
    if @organization_id == 3
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50] 
   end
 
  if @organization_id == 4
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50] 
   end
   
   return @group

   end
  
  def gathercat(g)
    
   p = Category.find_by_id(g.category_id)    
   @h = CategoryTitle.find_by_id(p.category_title_id)   
   @p = Category.find_all_by_parent_id(p.id)

   @group = @h.name
   @p.each do|pp|
   na=CategoryTitle.find_by_id(pp.category_title_id)
  
     @group = @group + symappend
     @group = @group + na.name    
   end
   
   return @group
    
  end
  
  def symappend
    @a = " << "
    return @a
  end  
  
  
  
  def gatherCatgeory(p)

    @organization_id = Setting.find(:first).organization_id
     
   if @organization_id == 1
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     section = Section.find_by_id_and_organization_id(p.section_id,@organization_id)
     
     @group = course.name + " << " + academicYear.name + " << " + section.name 
   end
   
   if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semester_id,@organization_id)
     
     @group = course.name + " << " + academicYear.name + " << " + department.name + " << " + semester.name
   end
 
    if @organization_id == 3
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group = academicYear.name + " << " + department.name 
   end
 
 if @organization_id == 4
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group = academicYear.name + " << " + department.name 
   end
   
   return @group
    

  end
  
end
