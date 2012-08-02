class Category < ActiveRecord::Base
  
  @organization_id = Setting.find(:first).organization_id    
  if @organization_id == 1
   validates_uniqueness_of :organization_id, :scope => [:course_id, :section_id], :message=>"Already exists"
  elsif @organization_id == 2
   validates_uniqueness_of :organization_id, :scope => [:course_id, :academic_year_id, :department_id, :semester_id], :message=>"Already exists"
  elsif @organization_id == 3 or @organization_id == 4
   validates_uniqueness_of :organization_id, :scope => [:department_id], :message=>"Already exists"    
 end
 
  belongs_to :category_title
  belongs_to :category_type
  
  has_many :categorysubject
  has_many :subjects, :through => :categorysubject
  
  has_many :categoryuser
  has_many :users, :through => :categoryuser
  
  def gathercat(p)
   @organization_id = Setting.find(:first).organization_id   
   
   if @organization_id == 1
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     section = Section.find_by_id_and_organization_id(p.section_id,@organization_id)    
     @group = course.name[0..40] + " << " + section.name[0..20] + " Section " 
   end
   
   if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semester_id,@organization_id)     
     @group = course.name[0..25] + " << "  + department.name[0..35] + " << " + academicYear.name[0..8] + " year " + " << " + semester.name[0..8] + " Semester "
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
  
  def symappend
    @a = " << "
    return @a
  end
  
end
