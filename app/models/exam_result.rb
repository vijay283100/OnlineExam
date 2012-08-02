class ExamResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :exam
  
  def getList(ul)
        
    users = "SELECT M.name as coursename,A.id as AcademicYear,S.name,S.subject,S.id,E.attempt,E.total_mark,E.score,E.percent,E.status
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join academic_years A on F.academic_year_id = A.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    Inner Join semesters P on F.semester_id = P.id
    where F.id = #{ul.categoryId} and U.id = #{ul.userId} and S.name = '#{ul.name}'
    Group By F.id,S.id,U.name,S.name,E.attempt,S.total_mark,E.percent;"
 
    @userIds = ExamResult.find_by_sql(users)    
    
    @userIds.each do|user|
      @arr = "#{user.score}"
      @sc = "#{user.total_mark}"
      return @arr, @sc
    end       
  end
  
  
  def dptReport(c_id, u_id, n,c_year,e_type)
    
    @organization_id = Setting.find(:first).organization_id
    if @organization_id == 1
          marks = "SELECT M.name as coursename,S.name,S.subject,S.id,E.attempt,E.total_mark,E.score,E.percent,E.status
                  From exam_results E
                  Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
                  AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
                  Inner Join categoryexams C on E.categoryexam_id = C.id
                  Inner Join categoryusers D on E.categoryuser_id = D.id
                  Inner Join categories F on C.category_id = F.id
                  Inner Join exams S on C.exam_id = S.id
                  Inner Join users U on D.user_id = U.id
                  Inner Join courses M on F.course_id = M.id
                  Inner Join sections N on F.section_id = N.id
                 Inner Join examtypes Y on C.examtype_id = Y.id
                  where F.id = #{c_id} and U.id = #{u_id} and S.name = '#{n}' and C.currentyear = #{c_year} and Y.id = #{e_type}
                  Group By F.id,S.id,U.name,S.name,E.attempt,S.total_mark,E.percent;"
             
             getMarks = ExamResult.find_by_sql(marks)
             
            unless getMarks.empty?
             getMarks.each do |g|
               unless g.score == nil
                 return g.score.to_f.round(2)
               else
                 return 0
               end
             end
            else
              return 0
            end
    end
    
    if @organization_id == 2
  
         marks = "SELECT M.name as coursename,A.id as AcademicYear,S.name,S.subject,S.id,E.attempt,E.total_mark,E.score,E.percent,E.status
                 From exam_results E
                  Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
                  AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
                  Inner Join categoryexams C on E.categoryexam_id = C.id
                  Inner Join categoryusers D on E.categoryuser_id = D.id
                  Inner Join categories F on C.category_id = F.id
                  Inner Join exams S on C.exam_id = S.id
                  Inner Join users U on D.user_id = U.id
                  Inner Join academic_years A on F.academic_year_id = A.id
                  Inner Join courses M on F.course_id = M.id
                  Inner Join departments N on F.department_id = N.id
                 Inner Join semesters P on F.semester_id = P.id
                 Inner Join examtypes Y on C.examtype_id = Y.id
                  where F.id = #{c_id} and U.id = #{u_id} and S.name = '#{n}' and C.currentyear = #{c_year} and Y.id = #{e_type}
                  Group By F.id,S.id,U.name,S.name,E.attempt,S.total_mark,E.percent,E.status;"
             
             getMarks = ExamResult.find_by_sql(marks)
            unless getMarks.empty?
             getMarks.each do |g|
               unless g.score == nil
                 return g.score.to_f.round(2)
               else
                 return 0
               end
             end
            else
              return 0
            end
    end
    
    if @organization_id == 3 or @organization_id == 4
          marks = "SELECT N.name as department,S.name,S.subject,S.id,E.attempt,E.total_mark,E.score,E.percent,E.status
                  From exam_results E
                  Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
                  AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
                  Inner Join categoryexams C on E.categoryexam_id = C.id
                  Inner Join categoryusers D on E.categoryuser_id = D.id
                  Inner Join categories F on C.category_id = F.id
                  Inner Join exams S on C.exam_id = S.id
                  Inner Join users U on D.user_id = U.id
                  Inner Join departments N on F.department_id = N.id
                 Inner Join examtypes Y on C.examtype_id = Y.id
                  where F.id = #{c_id} and U.id = #{u_id} and S.name = '#{n}' and C.currentyear = #{c_year} and Y.id = #{e_type}
                  Group By F.id,S.id,U.name,S.name,E.attempt,S.total_mark,E.percent;"
             
            getMarks = ExamResult.find_by_sql(marks)
            unless getMarks.empty?
             getMarks.each do |g|
               unless g.score == nil
                 return g.score.to_f.round(2)
               else
                 return 0
               end
             end
            else
              return 0
            end
    end    

  end

  def sqlGather(p)
    @organization_id = Setting.find(:first).organization_id
    if @organization_id == 2
     course = Course.find_by_id_and_organization_id(p.courseId,@organization_id)
     academicYear = AcademicYear.find_by_id_and_organization_id(p.yearId,@organization_id)
     department = Department.find_by_id_and_organization_id(p.departmentId,@organization_id)
     semester = Semester.find_by_id_and_organization_id(p.semesterId,@organization_id)
     
     @group = course.name + " << " + academicYear.name + " << " + department.name + " << " + semester.name
   end
  end
  
end
