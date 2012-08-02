class Categorysubject < ActiveRecord::Base
  
  belongs_to :category
  belongs_to :subject
    
  has_many :categoryexam
  has_many :exams, :through => :categoryexam
    
  has_many :subjectuser
  has_many :users, :through => :subjectuser  
    
  has_many :questions  
    
  def getuser(u,s)
    
    subjectUser = Subjectuser.find_by_user_id_and_categorysubject_id(u,s)
    if subjectUser
    return true
    else
      return false
    end
  end
    
 def gather_cat_sub(h)
      
     @organization_id = Setting.find(:first).organization_id

     p = Category.find_by_id_and_organization_id(h.category_id,@organization_id)
    @subject = Subject.find(h.subject_id)
   unless p == nil
   if @organization_id == 1
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     section = Section.find_by_id_and_organization_id(p.section_id,@organization_id)
     
     @group = course.name[0..40] + " << " + section.name[0..25] + "Section"
   end
  end
  
  unless p == nil
   if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.course_id,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.academic_year_id,@organization_id)
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semester_id,@organization_id)
     
     @group = course.name[0..20] + " << " + department.name[0..30] + " << " + academicYear.name[0..8]+ " year " + " << " + semester.name[0..8]+ " Semester "
   end
  end
  
  unless p == nil
    if @organization_id == 3
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50]
    end
  end
  
  unless p == nil
  if @organization_id == 4
     department = Department.find_by_id_and_organization_id(p.department_id,@organization_id)
     
     @group =  department.name[0..50]
  end
  end
  
   unless p == nil
   return @group + " << " + @subject.name[0..25]
   end

 end
    
    
  def symappend
    @a = " << "
    return @a
  end
end
