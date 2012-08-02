class EvaluateExam < ActiveRecord::Base
  validates_uniqueness_of :exam_id, :scope => [:user_id]
  
  belongs_to :user
  belongs_to :exam
  
  
   def evalCategory(e)
    
   @organization_id = Setting.find(:first).organization_id   
   
   if @organization_id == 1
     c = Category.find_by_id(e.category_id)    
     course = Course.find_by_id_and_organization_id(c.course_id,@organization_id)
     section = Section.find_by_id_and_organization_id(c.section_id,@organization_id)    
     @group = course.name[0..40] + " << " + section.name[0..20] + " Section " 
   end
   
   if @organization_id == 2
     c = Category.find_by_id(e.category_id) 
     course = Course.find_by_id_and_organization_id(c.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(c.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(c.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(c.semester_id,@organization_id)     
     @group = course.name[0..25] + " << "  + department.name[0..35] + " << " + academicYear.name[0..8] + " year " + " << " + semester.name[0..8] + " Semester "
   end
 
    if @organization_id == 3
     c = Category.find_by_id(e.category_id)      
     department = Department.find_by_id_and_organization_id(c.department_id,@organization_id)    
     @group =  department.name[0..50] 
   end
 
   if @organization_id == 4
     c = Category.find_by_id(e.category_id)     
     department = Department.find_by_id_and_organization_id(c.department_id,@organization_id)    
     @group =  department.name[0..50] 
   end   
   return @group
   
   end
  
   def categoryId(e)
     c = Category.find_by_id(e.category_id) 
     return c.id
   end
  
end
