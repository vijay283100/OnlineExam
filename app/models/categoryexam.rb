class Categoryexam < ActiveRecord::Base
  validates_uniqueness_of :currentyear, :scope => [:category_id, :exam_id, :examtype_id], :message=>"Already exists"

  belongs_to :category
  belongs_to :exam
  belongs_to :examtype
  
  has_many :categoryexamuser
  has_many :categoryusers, :through => :categoryexamuser
  
    def gathercat(g)
      
      p = Category.find_by_id(g.category_id)
      @organization_id = Setting.find(:first).organization_id   
      
   if @organization_id == 1
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     section = Section.find_by_id_and_organization_id(p.section_id,@organization_id)    
     @group = course.name[0..40] + " << " + section.name[0..20] + "Section" + " << " + g.currentyear
   end
   
   if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semester_id,@organization_id)
     
     @group = course.name[0..25] + " << " + academicYear.name[0..35] + " year " + " << " + department.name[0..8] + " << " + semester.name[0..8] + " semester " + " << " + g.currentyear
   end
 
    if @organization_id == 3
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50] + " << " + g.currentyear
   end
 
  if @organization_id == 4
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50] + " << " + g.currentyear
   end
   
   return @group

   end
  
  def symappend
    @a = " << "
    return @a
  end 
  
end
