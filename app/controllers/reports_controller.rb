class ReportsController < ApplicationController

  require 'csv'
  require 'prawn'
  filter_access_to :all
  
  layout :choose_layout
  def choose_layout
    if action_name == 'generateUser'
      return 'userReport'
    else
      return 'application'
    end
  end  
  
  def index
  end

  def userReport
    @organization_id = Setting.find(:first).organization_id
    @yrs = Array.new(10){|i| Date.current.year-i}
    @examTypes = Examtype.where(['organization_id = ?',@organization_id])
    @c = Category.where(['organization_id = ?',@organization_id])
    @category_id = params[:examCategory].to_i
     @academicYear = params[:academicYear].to_i
     @examtype = params[:examtype].to_i
     category_id = params[:examCategory].to_i
     academicYear = params[:academicYear].to_i
     examtype = params[:examtype].to_i
    unless @category_id == 0
      sql = "SELECT  distinct U.Name, U.id as userid, D.category_id as categoryid, D.currentyear as academicyear, C.examtype_id as examtype 
          FROM       categoryexamusers Q 
          Inner Join categoryusers D on Q.categoryuser_id = D.id
          Inner Join categoryexams C on Q.categoryexam_id = C.id
          Inner Join users U on D.user_id = U.id
          where C.category_id= #{category_id}    and D.currentyear = #{academicYear} and C.examtype_id = #{examtype};" 
          @category_user = Categoryuser.find_by_sql(sql)
    end 
   end

   def viewuserReport
   
     user = params[:user_id].to_i
     category_id = params[:category_id].to_i
     academicYear = params[:academicYear].to_i
     examtype = params[:examType].to_i
    
      sql = "SELECT E.examname,C.id as categoryexamId,C.examtype_id as examType, D.id as categoryuserId,U.name as username,Q.attempt,E.total_mark,E.score,E.percent,E.status,E.result_pending
      From exam_results E
      Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
      AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
      Inner Join categoryexams C on E.categoryexam_id = C.id
      Inner Join categoryusers D on E.categoryuser_id = D.id
      Inner Join categories F on C.category_id = F.id
      Inner Join exams S on C.exam_id = S.id
      Inner Join users U on D.user_id = U.id
      Inner Join examtypes Y on C.examtype_id = Y.id
      where U.id = #{user} and C.category_id= #{category_id}  and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
      Group By C.id;"
      
      @results = Evaluation.find_by_sql(sql)    
   end
   
   def userSubjectwise
     @organization_id = Setting.find(:first).organization_id
     if @organization_id == 1      
       user = params[:user_id].to_i
       category_id = params[:category_id].to_i
       academicYear = params[:academicYear].to_i
       examtype = params[:examType].to_i
        sql = "SELECT M.name as course, N.name as section,Y.name as examtype,E.examname,C.id as categoryexamId,C.examtype_id as examType, D.id as categoryuserId,U.name as username,Q.attempt,E.total_mark,E.score,E.percent,E.status,E.result_pending
        From exam_results E
        Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
        AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
        Inner Join categoryexams C on E.categoryexam_id = C.id
        Inner Join categoryusers D on E.categoryuser_id = D.id
        Inner Join categories F on C.category_id = F.id
        Inner Join exams S on C.exam_id = S.id
        Inner Join users U on D.user_id = U.id
        Inner Join examtypes Y on C.examtype_id = Y.id
        Inner Join courses M on F.course_id = M.id
        Inner Join sections N on F.section_id = N.id     
        where U.id = #{user} and C.category_id= #{category_id}  and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
        Group By C.id;"
        
        @results = Evaluation.find_by_sql(sql)        
            @results.each do|r|
              @username = r.username
              @course = r.course
              @section = r.section
              @academicyear = academicYear.to_s
              @examtype = r.examtype
            end
        if params[:pdf].to_i == 1
              @outfile = "userReport" + ".pdf"
              pdftable = Prawn::Document.new              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)  
            unless @course == nil
              pdftable.text(t('user.examinee') + ": " + @username) 
              pdftable.text(t('org.class') + ": " + @course) 
              pdftable.text(t('org.section') + ": " + @section)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
            else
              pdftable.text(t('user.examinee') + ": " + "")
              pdftable.text(t('org.class') + ": " + "") 
              pdftable.text(t('org.section') + ": " + "")
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")
            end              
              pdftable.table([[t('exam.name'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
               pdftable.table([["#{r.examname}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["ffffff"]
               )
              end

             send_data pdftable.render, :filename=>"default_filename.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
            @outfile = "userReport" + ".csv"
            @infile = ""            
             csv_data = CSV::Writer.generate(@infile) do |csv|
              csv << [
              t('user.examinee') + ": " "#{@username}",
              t('org.class') + ": " "#{@course}",
              t('org.section') + ": " "#{@section}",
      
              t('general.acedemic_yr') + ": " "#{@academicyear}",
              t('exam.exam_type') + ": " "#{@examtype}"
              ]  
              
              csv << [
              ]
              
            csv << [
            t('exam.name'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
              
              @results.each do|r|
                 csv << [
                   "#{r.examname}",
                   "#{r.attempt}",
                   "#{r.total_mark}",
                   "#{r.score}",
                   "#{r.percent}",
                   r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                 ]
              end
      
              end
            send_data @infile,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=#{@outfile}"
        end
    end
     
     
    if @organization_id == 2
      
     user = params[:user_id].to_i
     category_id = params[:category_id].to_i
     academicYear = params[:academicYear].to_i
     examtype = params[:examType].to_i
     sql = "SELECT M.name as course, N.name as department, O.name as academicYear, P.name as semester,Y.name as examtype,E.examname,C.id as categoryexamId,C.examtype_id as examType, D.id as categoryuserId,U.name as username,Q.attempt,E.total_mark,E.score,E.percent,E.status,E.result_pending
      From exam_results E
      Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
      AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
      Inner Join categoryexams C on E.categoryexam_id = C.id
      Inner Join categoryusers D on E.categoryuser_id = D.id
      Inner Join categories F on C.category_id = F.id
      Inner Join exams S on C.exam_id = S.id
      Inner Join users U on D.user_id = U.id
      Inner Join examtypes Y on C.examtype_id = Y.id
      Inner Join courses M on F.course_id = M.id
      Inner Join departments N on F.department_id = N.id
      Inner Join academic_years O on F.academic_year_id = O.id
      Inner Join semesters P on F.semester_id = P.id      
      where U.id = #{user} and C.category_id= #{category_id}  and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
      Group By C.id"
      
      @results = Evaluation.find_by_sql(sql)
      @results.each do|r|
        @username = r.username
        @course = r.course
        @department = r.department
        @year = r.academicYear
        @semester = r.semester
        @academicyear = academicYear.to_s
        @examtype = r.examtype
      end
      
      if params[:pdf].to_i == 1                        
              @outfile = "userReport" + ".pdf"
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100              
              pdftable.move_down(60)
              unless @course == nil
                pdftable.text(t('user.examinee') + ": " + @username) 
                pdftable.text(t('org.course') + ": " + @course) 
                pdftable.text(t('org.dept') + ": " + @department)
                pdftable.text(t('org.year') + ": " + @year + " year")
                pdftable.text(t('org.semester') + ": " + @semester + " semester")
                pdftable.text(t('exam.exam_type') + ": " + @examtype)
                pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              else
                pdftable.text(t('user.examinee') + ": " + "")
                pdftable.text(t('org.course') + ": " + "") 
                pdftable.text(t('org.dept') + ": " + "")
                pdftable.text(t('org.year') + ": " + "")
                pdftable.text(t('org.semester') + ": " +  "")
                pdftable.text(t('exam.exam_type') + ": " + "")
                pdftable.text(t('general.acedemic_yr') + ": " + "")
              end
              

              pdftable.table([[t('exam.name'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
               pdftable.table([["#{r.examname}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 },:row_colors => ["FFFFFF","DDDDDD"]
               )
              end

             send_data pdftable.render, :filename=>"user_report.pdf", :type=>"application/pdf"
           
      end

      if params[:csv].to_i == 1              
           @outfile = "userReport" + ".csv"
           @infile = ""
          
          csv_data = CSV::Writer.generate(@infile) do |csv|
            
            csv << [
            t('user.examinee') + ": " "#{@username}",
            t('org.course') + ": " "#{@course}",
            t('org.dept') + ": " "#{@department}",
            t('org.year') + ": " "#{@year}",
            t('org.semester') + ": " "#{@semester}",
            t('general.acedemic_yr') + ": " "#{@academicyear}",
            t('exam.exam_type') + ": " "#{@examtype}"
            ]  
            
            csv << [
            ]
            
            csv << [
            t('exam.name'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
            
            @results.each do|r|
               csv << [
                 "#{r.examname}",
                 "#{r.attempt}",
                 "#{r.total_mark}",
                 "#{r.score}",
                 "#{r.percent}",
                 r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
               ]
            end
    
            end
               send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}"
       end

    end
    
    if @organization_id == 3 or @organization_id == 4
     user = params[:user_id].to_i
     category_id = params[:category_id].to_i
     academicYear = params[:academicYear].to_i
     examtype = params[:examType].to_i
     sql = "SELECT N.name as department,Y.name as examtype,E.examname,C.id as categoryexamId,C.examtype_id as examType, D.id as categoryuserId,U.name as username,Q.attempt,E.total_mark,E.score,E.percent,E.status,E.result_pending
      From exam_results E
      Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
      AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
      Inner Join categoryexams C on E.categoryexam_id = C.id
      Inner Join categoryusers D on E.categoryuser_id = D.id
      Inner Join categories F on C.category_id = F.id
      Inner Join exams S on C.exam_id = S.id
      Inner Join users U on D.user_id = U.id
      Inner Join examtypes Y on C.examtype_id = Y.id
      Inner Join departments N on F.department_id = N.id     
      where U.id = #{user} and C.category_id= #{category_id}  and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
      Group By C.id"
      
      @results = Evaluation.find_by_sql(sql)     
      @results.each do|r|
        @username = r.username
        @department = r.department
        
        @academicyear = academicYear.to_s
        @examtype = r.examtype
      end
      
       if params[:pdf].to_i == 1
              @outfile = "userReport" + ".pdf"
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              unless @department ==nil
               pdftable.text(t('user.examinee') + ": " + @username) 
               pdftable.text(t('org.dept') + ": " + @department) 
               pdftable.text(t('exam.exam_type') + ": " + @examtype)
               pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
             else
              pdftable.text(t('user.examinee') + ": " + "") 
              pdftable.text(t('org.dept') + ": " + "") 
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")              
              end
              
              pdftable.table([[t('exam.name'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
               pdftable.table([["#{r.examname}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["ffffff"]
               )
              end
             send_data pdftable.render, :filename=>"default_filename.pdf", :type=>"application/pdf"
       end
       
      if params[:csv].to_i == 1
      @outfile = "userReport" + ".csv"
      @infile = ""
      
      csv_data = CSV::Writer.generate(@infile) do |csv|
        
        csv << [
        t('uase.examinee') + ": " "#{@username}",
        t('org.dept') + ": " "#{@department}",

        t('org.acedemic_yr') + ": " "#{@academicyear}",
        t('exam.exam_type') + ": " "#{@examtype}"
        ]  
        
        csv << [
        ]
        
            csv << [
            t('exam.name'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
        
        @results.each do|r|
           csv << [
             "#{r.examname}",
             "#{r.attempt}",
             "#{r.total_mark}",
             "#{r.score}",
             "#{r.percent}",
             r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
           ]
        end
        end
             send_data @infile,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"
    end
   end
   end
   
   def generateUser     
     @organization_id = Setting.find(:first).organization_id              
      if @organization_id == 1

      if params[:pdf].to_i == 1
           @categoryexamId = params[:categoryexam_id].to_i
           @categoryuserId = params[:categoryuser_id].to_i
           @attempt = params[:attempt].to_i
           @findCategoryuser = Categoryuser.find_by_id(@categoryuserId)
           @findCategoryexam = Categoryexam.find_by_id(@categoryexamId)           
           @findCategory = Category.find_by_id(@findCategoryexam.category_id)                      
           @findCourse = Course.find_by_id(@findCategory.course_id)
           @findSection= Section.find_by_id(@findCategory.section_id)
           
           @findUser = User.find_by_id(@findCategoryuser.user_id)
           @findExam = Exam.find_by_id(@findCategoryexam.exam_id)
           
           @findExamtype = Examtype.find_by_id(@findCategoryexam.examtype_id)
           
      
           @evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt]).map{ |i| i.question_id }.uniq
      
           
           @answerd = evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt])
      
          @login_count = 1
            @username = @findUser.is_temp_examinee == 1 ? @findUser.login : @findUser.name


      end
     end  
      
      if @organization_id == 2
        
 
     if params[:pdf].to_i == 1
         @categoryexamId = params[:categoryexam_id].to_i
         @categoryuserId = params[:categoryuser_id].to_i
         @attempt = params[:attempt].to_i
          
         @findCategoryuser = Categoryuser.find_by_id(@categoryuserId)
         @findCategoryexam = Categoryexam.find_by_id(@categoryexamId)         
         @findCategory = Category.find_by_id(@findCategoryexam.category_id)
         @findDepartment = Department.find_by_id(@findCategory.department_id)
         @findyear = AcademicYear.find_by_id(@findCategory.academic_year_id)
         @findCourse = Course.find_by_id(@findCategory.course_id)
         @findSemester= Semester.find_by_id(@findCategory.semester_id)        
         @findUser = User.find_by_id(@findCategoryuser.user_id)
         @findExam = Exam.find_by_id(@findCategoryexam.exam_id)         
         @findExamtype = Examtype.find_by_id(@findCategoryexam.examtype_id)
         
          #evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", categoryexamId,categoryuserId,attempt])#.select('DISTINCT question_id')
      
           @evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt]).map{ |i| i.question_id }.uniq
      
           
          @answerd = evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt])
          @outfile = "AnswerSheet" + ".pdf"
      
          @login_count = 1
          @username = @findUser.is_temp_examinee == 1 ? @findUser.login : @findUser.name
      end   
  end
  
      if @organization_id == 3 or @organization_id == 4
        
    
       if params[:pdf].to_i == 1
           @categoryexamId = params[:categoryexam_id].to_i
           @categoryuserId = params[:categoryuser_id].to_i
           @attempt = params[:attempt].to_i
           
           @findCategoryuser = Categoryuser.find_by_id(@categoryuserId)
           @findCategoryexam = Categoryexam.find_by_id(@categoryexamId)
           
           @findCategory = Category.find_by_id(@findCategoryexam.category_id)
           
           
           @findDepartment = Department.find_by_id(@findCategory.department_id)
           
           @findUser = User.find_by_id(@findCategoryuser.user_id)
           @findExam = Exam.find_by_id(@findCategoryexam.exam_id)
           
           @findExamtype = Examtype.find_by_id(@findCategoryexam.examtype_id)
           
           #evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", categoryexamId,categoryuserId,attempt])#.select('DISTINCT question_id')
      
           @evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt]).map{ |i| i.question_id }.uniq
      
           
           @answerd = evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexamId,@categoryuserId,@attempt])
          @outfile = "AnswerSheet" + ".pdf"
      
          @login_count = 1
          @username = @findUser.is_temp_examinee == 1 ? @findUser.login : @findUser.name
           
       end    
      end       
  end
 
  def examReport
    @organization_id = Setting.find(:first).organization_id
    @c = Category.where(['organization_id = ?',@organization_id])
    @category_id = params[:examCategory].to_i
    @academicYear = params[:academicYear].to_i
    @examtype = params[:examtype].to_i
    @yrs = Array.new(10){|i| Date.current.year-i}
    @examTypes = Examtype.where(['organization_id = ?',@organization_id])
    unless @category_id == 0
      @academicYear = params[:academicYear].to_i
      @examtype = params[:examtype].to_i
      @category_exam = Categoryexam.where(["category_id = ? and currentyear = ? and examtype_id = ?",@category_id,@academicYear,@examtype])
    end 
  end
  
  def viewexamReport
       exam = params[:exam_id].to_i
       semesterId = params[:semester_id].to_i
     category_id = params[:category_id].to_i
     academicYear = params[:currentyear].to_i
     examtype = params[:examType]
       
        sql = "SELECT S.id as examid, U.id, U.name,U.login,U.is_temp_examinee as tempexaminee,Q.attempt,E.total_mark,E.score,E.percent,E.status,E.result_pending 
    From exam_results E
    Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
     AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    
    where S.id = #{exam} and C.category_id= #{category_id} and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
    group by S.id, U.id, U.name,Q.attempt,E.total_mark,E.score,E.percent,E.status;"
        
        @results = Evaluation.find_by_sql(sql)              
  end
  
  def generateExamReport
    @organization_id = Setting.find(1).organization_id
    if @organization_id == 1
      exam = params[:exam_id].to_i
      semesterId = params[:semester_id].to_i
      category_id = params[:category_id].to_i
      academicYear = params[:currentyear].to_i
      examtype = params[:examType]
     
    sql = "SELECT S.id as examid,S.name as examname,D.currentyear as studyingyear, U.id, U.name,U.login,U.is_temp_examinee as tempexaminee,Q.attempt,E.total_mark,E.score,E.percent,E.status,M.name as course, N.name as section,Y.name as examtype,E.result_pending 
    From exam_results E
    Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
     AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    
    where S.id = #{exam} and C.category_id= #{category_id} and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
    group by S.id, U.id, U.name,Q.attempt,E.total_mark,E.score,E.percent,E.status;" 
        
      @results = Evaluation.find_by_sql(sql)     
             @results.each do|r|
              @course = r.course
              @section = r.section
              @studyingyear = r.studyingyear
              @examtype = r.examtype
              @examname = r.examname
            end  
      if params[:pdf].to_i == 1
        
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              unless @course == nil
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.class') + ": " + @course) 
              pdftable.text(t('org.section') + ": " + @section)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              pdftable.text(t('general.acedemic_yr') + ": " + @studyingyear)
              
            else
              pdftable.text(t('exam.name') + ": " + "")
              pdftable.text(t('org.class') + ": " + "") 
              pdftable.text(t('org.section') + ": " + "")
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")
              
              end
            
              pdftable.table([[t('user.examinee'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"examReport.pdf", :type=>"application/pdf"
          end
      
      if params[:csv].to_i == 1
        @outfile = "examReport" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
          
             csv << [
             t('exam.name') + ": " "#{@examname}",
              t('org.class') + ": " "#{@course}",
              t('org.section') + ": " "#{@section}",
              t('general.acedemic_yr') + ": " "#{@studyingyear}",
              t('exam.exam_type') + ": " "#{@examtype}"              
              ] 
          
            csv << [
            t('user.examinee'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
          
          @results.each do|r|
             csv << [
               "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
               "#{r.attempt}",
               "#{r.total_mark}",
               "#{r.score}",
               "#{r.percent}",
               r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
             ]
          end
  
          end
         send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
      end
    end
    
    
    if @organization_id == 2
      exam = params[:exam_id].to_i
      semesterId = params[:semester_id].to_i
      category_id = params[:category_id].to_i
      academicYear = params[:currentyear].to_i
      examtype = params[:examType]
     
    sql = "SELECT S.id as examid,S.name as examname,D.currentyear as studyingyear, U.id, U.name,U.login,U.is_temp_examinee as tempexaminee,Q.attempt,E.total_mark,E.score,E.percent,E.status,M.name as course, N.name as department, O.name as academicYear, P.name as semester,Y.name as examtype,E.result_pending 
    From exam_results E
    Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
     AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join examtypes Y on C.examtype_id = Y.id
      Inner Join courses M on F.course_id = M.id
      Inner Join departments N on F.department_id = N.id
      Inner Join academic_years O on F.academic_year_id = O.id
      Inner Join semesters P on F.semester_id = P.id
    
    where S.id = #{exam} and C.category_id= #{category_id} and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
    group by S.id, U.id, U.name,Q.attempt,E.total_mark,E.score,E.percent,E.status;" 
        @results = Evaluation.find_by_sql(sql)
      @results.each do|r|
        @course = r.course
        @department = r.department
        @year = r.academicYear
        @semester = r.semester
        @academicyear = r.studyingyear
        @examtype = r.examtype
        @examname = r.examname
      end 
      
      if params[:pdf].to_i == 1
        
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              
             pdftable.move_down(60) 
              unless @course == nil
                pdftable.text(t('exam.name') + ": " + @examname)
                pdftable.text(t('org.course') + ": " + @course) 
                pdftable.text(t('org.dept') + ": " + @department)
                pdftable.text(t('org.year') + ": " + @year + " year")
                pdftable.text(t('org.semester') + ": " + @semester + " semester")
                pdftable.text(t('exam.exam_type') + ": " + @examtype)
                pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              
            else
               pdftable.text(t('exam.name') + ": " + "")
                pdftable.text(t('org.course') + ": " + "") 
                pdftable.text(t('org.dept') + ": " + "")
                pdftable.text(t('org.year') + ": " + "")
                pdftable.text(t('org.semester') + ": " + "")
                pdftable.text(t('exam.exam_type') + ": " + "")
                pdftable.text(t('general.acedemic_yr') + ": " + "")
              
              end
              pdftable.table([[t('user.examinee'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"examReport.pdf", :type=>"application/pdf"
          end
      
      if params[:csv].to_i == 1
        @outfile = "examReport" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
          
            csv << [
            t('exam.name') + ": " "#{@examname}",
            t('org.course') + ": " "#{@course}",
            t('org.dept') + ": " "#{@department}",
            t('org.year') + ": " "#{@year}",
            t('org.semester') + ": " "#{@semester}",
            t('general.acedemic_yr') + ": " "#{@academicyear}",
            t('exam.exam_type') + ": " "#{@examtype}"
             
            ]  
          
            csv << [
            t('user.examinee'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
          
          @results.each do|r|
             csv << [
               "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
               "#{r.attempt}",
               "#{r.total_mark}",
               "#{r.score}",
               "#{r.percent}",
               r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
             ]
          end
  
          end
         send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
      end
    end    
        
    if @organization_id == 3 or @organization_id == 4
      exam = params[:exam_id].to_i
      semesterId = params[:semester_id].to_i
      category_id = params[:category_id].to_i
      academicYear = params[:currentyear].to_i
      examtype = params[:examType]
     
    sql = "SELECT S.id as examid,S.name as examname,D.currentyear as studyingyear, U.id, U.name,U.login,U.is_temp_examinee as tempexaminee,Q.attempt,E.total_mark,E.score,E.percent,E.status, N.name as department,Y.name as examtype,E.result_pending 
    From exam_results E
    Inner Join categoryexamusers Q on E.categoryuser_id = Q.categoryuser_id
     AND  E.categoryexam_id = Q.categoryexam_id AND E.attempt = Q.attempt
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    Inner Join departments N on F.department_id = N.id    
    where S.id = #{exam} and C.category_id= #{category_id} and C.currentyear = #{academicYear}  and C.examtype_id = #{examtype}
    group by S.id, U.id, U.name,Q.attempt,E.total_mark,E.score,E.percent,E.status;" 
        
      @results = Evaluation.find_by_sql(sql)  
      @results.each do|r|
        @department = r.department
        @academicyear = r.studyingyear
        @examtype = r.examtype
        @examname = r.examname
      end 
      
      if params[:pdf].to_i == 1
        
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              
              pdftable.move_down(60)
              unless @department == nil
                pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.dept') + ": " + @department) 
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              
            else
              pdftable.text(t('exam.name') + ": " + "")
              pdftable.text(t('org.dept') + ": " + "") 
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")
              
            end
            
              pdftable.table([[t('user.examinee'),t('exam.attempt'),t('exam.exam_mark'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["d5d5d5"])
              
              @results.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.attempt}","#{r.total_mark}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 150, 1 => 70, 2 => 70, 3 => 80, 4 => 70, 5 => 86, 6 => 100,7 => 100 }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"examReport.pdf", :type=>"application/pdf"
          end
      
      if params[:csv].to_i == 1
        @outfile = "examReport" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
          
            csv << [
            t('exam.name') + ": " "#{@examname}",
        t('org.dept') + ": " "#{@department}",
        t('org.acedemic_yr') + ": " "#{@academicyear}",
        t('exam.exam_type') + ": " "#{@examtype}"
        
            ]  
          
            csv << [
            t('user.examinee'),
            t('exam.attempt'),
            t('exam.exam_mark'),
            t('exam.mark_scored'),
            t('exam.percent'),
            t('general.status')
            ]
          
          @results.each do|r|
             csv << [
               "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
               "#{r.attempt}",
               "#{r.total_mark}",
               "#{r.score}",
               "#{r.percent}",
               r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
             ]
          end
  
          end
         send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
      end
    end  
    
    
    
  end


   def departmentReport
     @organization_id = Setting.find(:first).organization_id
     #@c = Category.find(:all).paginate(:page => params[:page], :per_page => 10)
     @c = Category.where(['organization_id = ?',@organization_id])
      @category_id = params[:examCategory].to_i
      @yrs = Array.new(10){|i| Date.current.year-i}
      @examTypes = Examtype.where(['organization_id = ?',@organization_id])
   end

  def generateDepartmentReport   
   @organization_id = Setting.find(1).organization_id
   examCategory = params[:examCategory].to_i
   academicyear = params[:academicYear].to_i
   examtype = params[:examtype].to_i
 
    if @organization_id == 1
      if params[:fileType].to_i == 1
        eH = []
    subjects = "SELECT  Distinct S.name
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)
    @examHeaders.each do|h|
      eH << h.name
    end

   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, M.name as coursename, N.name as section, Y.name as examType
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
          @userIds.each do|r|
              @course = r.coursename
              @section = r.section
              @academicyear = academicyear.to_s
              @examtype = r.examType
            end
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
        
             csv << [
              t('org.class') + ": " "#{@course}",
               t('org.section') + ": " "#{@section}",
              t('general.acedemic_yr') + ": " "#{@academicyear}",
              t('exam.exam_type') + ": " "#{@examtype}"
              ]  
              
              csv << [
              ]
        
        csv << [
        t('user.examinee')] +
         @examHeaders.map { |header| header.name } +
        [t('reports.grand_tot')]

        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, M.name as coursename, S.name,C.currentyear as currentyear, Y.id as examtype
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

     marks = "SELECT M.name as coursename,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status,max(E.attempt)
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent;"
    
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end

       end
       @tot = @grandTotal.inject{|sum,x| sum + x }

          
          @arr << "#{user.userId}"
          
           csv << [
             "#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"
             ] + 
             eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+  
           [@tot == nil ? 0 : @tot.to_f.round(2)]
           @grandTotal.clear
        end
      end
         send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
    end
    
    if params[:fileType].to_i == 0
      eH = []
    subjects = "SELECT  Distinct S.name
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)

    @examHeaders.each do|h|
      eH << h.name
    end

   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, M.name as coursename, N.name as section, Y.name as examType
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
            @userIds.each do|r|
              @course = r.coursename
              @section = r.section
              @academicyear = academicyear.to_s
              @examtype = r.examType
            end
    
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport" + ".csv"
      
      pdftable = Prawn::Document.new  

              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
         pdftable.move_down(60)
             unless @course== nil  
              pdftable.text(t('org.class') + ": " + @course) 
              pdftable.text(t('org.section') + ": " + @section)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear) 
             else
              pdftable.text(t('org.class') + ": " + "") 
              pdftable.text(t('org.section') + ": " + "")
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")
               
             end 
 

         pdftable.table([[t('user.examinee')] + 
         @examHeaders.map { |header| header.name } +
         [t('reports.grand_tot')]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["d5d5d5"])


        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, M.name as coursename, S.name,C.currentyear as currentyear, Y.id as examtype
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

     marks = "SELECT M.name as coursename,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status,max(E.attempt)
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent;"
    
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end

       end
       @tot = @grandTotal.inject{|sum,x| sum + x }
      
          
          @arr << "#{user.userId}"
          
         pdftable.table([["#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"] + 
         eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+  

         [@tot == nil ? 0 : @tot.to_f.round(2)]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["ffffff"])
          
           @grandTotal.clear
        end
        send_data pdftable.render, :filename=>"departmentReport.pdf", :type=>"application/pdf"
    end
    
    
    end
    
    if @organization_id == 2
      
    if params[:fileType].to_i == 1
      eH = []
    subjects = "SELECT  Distinct S.name
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)

    @examHeaders.each do|h|
      eH << h.name
    end

   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, M.name as coursename,A.name as AcademicYear,N.name as department, P.name as semester, Y.name as examType
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
    @userIds.each do|r|
        @course = r.coursename
        @department = r.department
        @year = r.AcademicYear
        @semester = r.semester
        @academicyear = academicyear.to_s
        @examtype = r.examType
      end
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
        
            csv << [
            t('org.course') + ": " "#{@course}",
            t('org.dept') + ": " "#{@department}",
            t('org.year') + ": " "#{@year}",
            t('org.semester') + ": " "#{@semester}",
            t('general.acedemic_yr') + ": " "#{@academicyear}",
            t('exam.exam_type') + ": " "#{@examtype}"
            ]  
        
          csv << [
            ]
 
        csv << [
        t('user.examinee')] +
         @examHeaders.map { |header| header.name } +
        [t('reports.grand_tot')]


        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, M.name as coursename,A.name as AcademicYear, S.name,C.currentyear as currentyear, Y.id as examtype
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

    marks = "SELECT M.name as coursename,A.id as AcademicYear,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent,E.status;"
    
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end

       end
       @tot = @grandTotal.inject{|sum,x| sum + x }
          
          @arr << "#{user.userId}"
          
           csv << [
             "#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"
           ] + 
            eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+  

           [@tot == nil ? 0 : @tot.to_f.round(2)]
           @grandTotal.clear
        end
        
      end
      send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
    end
    
    if params[:fileType].to_i == 0
      eH = []
    subjects = "SELECT  Distinct S.name
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)

    @examHeaders.each do|h|
      eH << h.name
    end

   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, M.name as coursename,A.name as AcademicYear,N.name as department, P.name as semester, Y.name as examType
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
      @userIds.each do|r|
        @course = r.coursename
        @department = r.department
        @year = r.AcademicYear
        @semester = r.semester
        @academicyear = academicyear.to_s
        @examtype = r.examType
      end
    
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport" + ".csv"
      
      pdftable = Prawn::Document.new  
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
     pdftable.move_down(60)
             unless @course== nil  
                pdftable.text(t('org.course') + ": " + @course) 
                pdftable.text(t('org.dept') + ": " + @department)
                pdftable.text(t('org.year') + ": " + @year + " year")
                pdftable.text(t('org.semester') + ": " + @semester + " semester")
                pdftable.text(t('exam.exam_type') + ": " + @examtype)
                pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
             else
                pdftable.text(t('org.course') + ": " + "") 
                pdftable.text(t('org.dept') + ": " + "")
                pdftable.text(t('org.year') + ": " + "")
                pdftable.text(t('org.semester') + ": " +  "")
                pdftable.text(t('exam.exam_type') + ": " + "")
                pdftable.text(t('general.acedemic_yr') + ": " + "")
             end   
         
          pdftable.table([[t('user.examinee')] + 
         @examHeaders.map { |header| header.name } +
         [t('reports.grand_tot')]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["d5d5d5"])


        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, M.name as coursename,A.name as AcademicYear, S.name,C.currentyear as currentyear, Y.id as examtype
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
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

    marks = "SELECT M.name as coursename,A.id as AcademicYear,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent,E.status;"
 
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end

       end
       @tot = @grandTotal.inject{|sum,x| sum + x }
          
          @arr << "#{user.userId}"
          
         pdftable.table([["#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"] + 
          eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+          
         [@tot == nil ? 0 : @tot.to_f.round(2)]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["ffffff"])
          
           @grandTotal.clear
        end
        send_data pdftable.render, :filename=>"departmentReport.pdf", :type=>"application/pdf"
    end
    
    end
    

    if @organization_id == 3 or @organization_id == 4
      
    if params[:fileType].to_i == 1  
      eH = []
    subjects = "SELECT  Distinct S.name
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)

    @examHeaders.each do|h|
      eH << h.name
    end

   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, N.name as department, Y.name as examType
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
    @userIds.each do|r|
        @department = r.department
        
        @academicyear = academicyear.to_s
        @examtype = r.examType
      end
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport-" + ".csv"
        @infile = ""
        csv_data = CSV::Writer.generate(@infile) do |csv|
        
        csv << [
        t('org.dept') + ": " "#{@department}",
        t('org.acedemic_yr') + ": " "#{@academicyear}",
        t('exam.exam_type') + ": " "#{@examtype}"
        ]
        
        csv << [
        ] 
        
        csv << [
        t('user.examinee')] +
         @examHeaders.map { |header| header.name } +
        [t('reports.grand_tot')]

        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, N.name as department, S.name,C.currentyear as currentyear, Y.id as examtype
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

     marks = "SELECT N.name as department,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status,max(E.attempt)
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent;"
    
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end
       end
       @tot = @grandTotal.inject{|sum,x| sum + x }
          
          @arr << "#{user.userId}"
          
           csv << [
             "#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"
           ] + 
            eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+  
           
           [@tot == nil ? 0 : @tot.to_f.round(2)]
           @grandTotal.clear
        end
        
      end
            send_data @infile,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}" 
    end
    
    if params[:fileType].to_i == 0
      eH = []
    subjects = "SELECT  Distinct S.name
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear} and Y.id = #{examtype};"
    
    @examHeaders = ExamResult.find_by_sql(subjects)

    @examHeaders.each do|h|
      eH << h.name
    end
    
   users = "SELECT  Distinct U.id as userId, U.name as username,U.login,U.is_temp_examinee as tempexaminee, F.id as categoryId, N.name as department, Y.name as examType
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{examCategory} and C.category_id = F.id and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
    
    @userIds = ExamResult.find_by_sql(users)
    
    @userIds.each do|r|
        @department = r.department
        
        @academicyear = academicyear.to_s
        @examtype = r.examType
      end
    
    @arr = []
    @grandTotal = []
      @outfile = "departmentReport" + ".csv"
      
      pdftable = Prawn::Document.new 
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              
          pdftable.move_down(60)
          
             unless @department== nil  
              pdftable.text(t('org.dept') + ": " + @department) 
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear) 
             else
              pdftable.text(t('org.dept') + ": " + "") 
              pdftable.text(t('exam.exam_type') + ": " + "")
              pdftable.text(t('general.acedemic_yr') + ": " + "")
             end   
                                        
         pdftable.table([[t('user.examinee')] + 
         @examHeaders.map { |header| header.name } +
         [t('reports.grand_tot')]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["d5d5d5"])

        @userIds.each do|user|

   samp = "SELECT  Distinct U.id as userId, U.name as username, F.id as categoryId, N.name as department, S.name,C.currentyear as currentyear, Y.id as examtype
    From exam_results E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments N on F.department_id = N.id
    Inner Join examtypes Y on C.examtype_id = Y.id
    where F.id = #{user.categoryId} and C.category_id = F.id and D.user_id = #{user.userId} and C.currentyear = #{academicyear}  and Y.id = #{examtype};"
          
       @get = ExamResult.find_by_sql(samp)    
       
       @get.each do|subject|

     marks = "SELECT N.name as department,S.name,S.subject,S.id,Q.attempt,E.total_mark,E.score,E.percent,E.status,max(E.attempt)
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
          where F.id = #{subject.categoryId} and U.id = #{subject.userId} and S.name = '#{subject.name}' and C.currentyear = #{academicyear}  and Y.id = #{examtype}
          Group By F.id,S.id,U.name,S.name,Q.attempt,S.total_mark,E.percent;"
 
            getMarks = ExamResult.find_by_sql(marks)
              getMarks.each do|g|
              @grandTotal << "#{g.score}".to_f
          end

       end
       @tot = @grandTotal.inject{|sum,x| sum + x }
          
          @arr << "#{user.userId}"
          
         pdftable.table([["#{user.tempexaminee}" == '1' ? "#{user.login}" : "#{user.username}"] + 
            eH.map{ |e|  @get.map { |subject,i| e==subject.name ? subject.dptReport(subject.categoryId,subject.userId,subject.name,subject.currentyear,subject.examtype) : 0 }.compact.inject(:+)}+  
         
         [@tot == nil ? 0 : @tot.to_f.round(2)]],
         :column_widths => {0 => 50, 1 => 50, 2 => 50, 3=>50,4=>50,5=>50,6=>50,7=>50,8=>50,9=>50,10=>50,11=>50,12=>50,13=>50,14=>50,15=>50, }, :row_colors => ["ffffff"])
          
           @grandTotal.clear
        end
        send_data pdftable.render, :filename=>"departmentReport.pdf", :type=>"application/pdf"
    end
    end
  end
  
  def overall
     @organization_id = Setting.find(:first).organization_id
     @academicYear = AcademicYear.where(["organization_id = ?",@organization_id])
     academicYear = params[:academicYear].to_i
     @y = params[:academicYear].to_i
     @yrs = Array.new(10){|i| Date.current.year-i}
     @examTypes = Examtype.where(["organization_id = ?",@organization_id])
     dateTime = Time.now()
     currentyear = dateTime.year
     if @organization_id == 1 or @organization_id == 2
      unless academicYear >= 1
             eType = Examtype.where(["organization_id = ?",@organization_id])
        unless eType.empty?
             examtypeFirst = Examtype.where(["organization_id = ?",@organization_id]).first.id
             @examtype_id = examtypeFirst
        else
             examtypeFirst = 0
             @examtype_id = examtypeFirst
        end   
               
    yrs = "SELECT A.courseId,A.name,A.currentyear,A.TotalUser,FailedUser,    
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage     
    FROM(
    Select M.id as courseId,M.name,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    where  C.currentyear = #{currentyear}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtypeFirst}
    GROUP BY M.id,M.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,name,currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    where  C.currentyear = #{currentyear}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtypeFirst}
     ) A
    WHERE Pass=0
    GROUP BY courseId,name,currentyear) B
    ON A.courseId= B.courseId AND A.currentyear = B.currentyear"
       
       @allYears = ExamResult.find_by_sql(yrs)
      else
       @examtype_id = params[:examtype_id].to_i
     examtype_id = params[:examtype_id].to_i     
      
    yrs = "SELECT A.courseId,A.name,A.currentyear,A.TotalUser,FailedUser, 
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage 
    FROM(
    Select M.id as courseId,M.name,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    where  C.currentyear = #{academicYear}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id}
    GROUP BY M.id,M.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,name,currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    where  C.currentyear = #{academicYear}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id}
     ) A
    WHERE Pass=0
    GROUP BY courseId,name,currentyear) B
    ON A.courseId= B.courseId AND A.currentyear = B.currentyear"
       
        @allYears = ExamResult.find_by_sql(yrs)
      end
    end    
    
    if @organization_id == 3 or @organization_id == 4
      unless academicYear >= 1
        
       eType = Examtype.where(["organization_id = ?",@organization_id])
        unless eType.empty?
             examtypeFirst = Examtype.where(["organization_id = ?",@organization_id]).first.id
             @examtype_id = examtypeFirst
        else
             examtypeFirst = 0
             @examtype_id = examtypeFirst
        end  
                
    yrs = "SELECT A.departmentId,A.name,A.currentyear,A.TotalUser,FailedUser,

    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage
  
    FROM(
    Select M.id as departmentId,M.name,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments M on F.department_id = M.id
    where  C.currentyear = #{currentyear}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtypeFirst}
    GROUP BY M.id,M.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT departmentId,name,currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as departmentId,M.name,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments M on F.department_id = M.id
    where  C.currentyear = #{currentyear}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtypeFirst}
     ) A
    WHERE Pass=0
    GROUP BY departmentId,name,currentyear) B
    ON A.departmentId= B.departmentId AND A.currentyear = B.currentyear"
       
        @allYears = ExamResult.find_by_sql(yrs)
      else
        @examtype_id = params[:examtype_id].to_i
     examtype_id = params[:examtype_id].to_i      
     
    yrs = "SELECT A.departmentId,A.name,A.currentyear,A.TotalUser,FailedUser,
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage 
    FROM(
    Select M.id as departmentId,M.name,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments M on F.department_id = M.id
    where  C.currentyear = #{academicYear}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id}
    GROUP BY M.id,M.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT departmentId,name,currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as departmentId,M.name,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join departments M on F.department_id = M.id
    where  C.currentyear = #{academicYear}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id}
     ) A
    WHERE Pass=0
    GROUP BY departmentId,name,currentyear) B
    ON A.departmentId= B.departmentId AND A.currentyear = B.currentyear"
       
        @allYears = ExamResult.find_by_sql(yrs)
      end
    end
    
  end
  
  def specificDepartment
    @organization_id = Setting.find(:first).organization_id
    @examtype_id = params[:examtype_id].to_i
    examtype_id = params[:examtype_id].to_i
    courseId = params[:course_id].to_i
    yearId = params[:year_id].to_i

    if @organization_id == 1
    yrs = "SELECT A.courseId,A.coursename, A.section_id,A.sectionname,A.currentyear,A.TotalUser,FailedUser,
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage  
    FROM(
    Select M.id as courseId,M.name AS coursename,N.id AS section_id,N.name AS sectionname,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    where  C.currentyear = #{yearId} and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId}
    GROUP BY M.id,M.name,N.id,N.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,coursename, section_id,sectionname, currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name AS coursename,N.id AS section_id,N.name AS sectionname,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join sections N on F.section_id = N.id
    where  C.currentyear = #{yearId} and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId}
     ) A
    WHERE Pass=0
    GROUP BY courseId,coursename, section_id,sectionname,currentyear) B
    ON A.courseId= B.courseId AND A.section_id= B.section_id AND A.currentyear = B.currentyear"      
      

      @allYears = ExamResult.find_by_sql(yrs)
    end

    if @organization_id == 2
    yrs = "SELECT A.courseId,A.coursename, A.department_id,A.departmentname,A.currentyear,A.TotalUser,FailedUser,
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage  
    FROM(
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    where  C.currentyear = #{yearId}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId}
    GROUP BY M.id,M.name,N.id,N.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,coursename, department_id,departmentname, currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    where  C.currentyear = #{yearId}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId}
     ) A
    WHERE Pass=0
    GROUP BY courseId,coursename, department_id,departmentname,currentyear) B
    ON A.courseId= B.courseId AND A.department_id= B.department_id AND A.currentyear = B.currentyear"
     
      @allYears = ExamResult.find_by_sql(yrs)
    end

  end
  
  def departmentDetailed
    courseId = params[:course_id].to_i
    yearId = params[:year_id].to_i
    departmentId = params[:department_id].to_i
    @examtype_id = params[:examtype_id].to_i
    examtype_id = params[:examtype_id].to_i
    @organization_id = Setting.find(:first).organization_id
     yrs = "SELECT A.courseId,A.coursename, A.department_id,A.departmentname,A.year_id,A.yearname,A.currentyear,A.TotalUser,FailedUser,
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage  
    FROM(
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,Y.id AS year_id,Y.name AS yearname,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    Inner Join academic_years Y on F.academic_year_id = Y.id
    where  C.currentyear = #{yearId} and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId} and F.department_id = #{departmentId}
    GROUP BY M.id,M.name,N.id,N.name,Y.id,Y.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,coursename, department_id,departmentname,year_id,yearname, currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,Y.id AS year_id,Y.name AS yearname,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    Inner Join academic_years Y on F.academic_year_id = Y.id
    where  C.currentyear = #{yearId}  and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId} and F.department_id = #{departmentId}
     ) A
    WHERE Pass=0
    GROUP BY courseId,coursename, department_id,departmentname,year_id,yearname,currentyear) B
    ON A.courseId= B.courseId AND A.department_id= B.department_id AND A.year_id=B.year_id AND A.currentyear = B.currentyear"     
      @allYears = ExamResult.find_by_sql(yrs)
  end
   
  def semesterDetailed
    courseId = params[:course_id].to_i
    yearId = params[:year_id].to_i
    departmentId = params[:department_id].to_i
    acadyear= params[:acayear_id].to_i
    @examtype_id = params[:examtype_id].to_i
    examtype_id = params[:examtype_id].to_i
    @organization_id = Setting.find(:first).organization_id
    
    semester = "SELECT A.courseId,A.coursename, A.department_id,A.departmentname,A.year_id,A.yearname,A.semester_id,A.semestername,A.currentyear,A.TotalUser,FailedUser,
    IFNULL(TotalUser,0) -IFNULL(FailedUser,0) AS PassedUsers,
    ((IFNULL(TotalUser,0) - IFNULL(FailedUser,0)) / IFNULL(TotalUser,0) )*100 AS Totalpercentage  
    FROM(
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,Y.id AS year_id,Y.name AS yearname,K.id AS semester_id,K.name AS semestername,C.currentyear as currentyear, COUNT( D.user_id)AS TotalUser
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    Inner Join academic_years Y on F.academic_year_id = Y.id
    Inner Join semesters K on F.semester_id = K.id
    where  C.currentyear = #{yearId}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId} and F.department_id = #{departmentId} and F.academic_year_id = #{acadyear}
    GROUP BY M.id,M.name,N.id,N.name,Y.id,Y.name,K.id,K.name,C.currentyear) A
    
    LEFT JOIN(
     SELECT courseId,coursename, department_id,departmentname,year_id,yearname,semester_id,semestername, currentyear,COUNT(user_id)AS FailedUser
    FROM (
    Select M.id as courseId,M.name AS coursename,N.id AS department_id,N.name AS departmentname,Y.id AS year_id,Y.name AS yearname,K.id AS semester_id,K.name AS semestername,C.currentyear as currentyear, C.category_id,C.exam_id,
    D.user_id,     Q.Status , CASE WHEN Q.Status='P' THEN  1 ELSE 0 END AS Pass
    from categoryexamusers Q  Inner Join categoryexams C on Q.categoryexam_id = C.id
    Inner Join categoryusers D on Q.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    Inner Join courses M on F.course_id = M.id
    Inner Join departments N on F.department_id = N.id
    Inner Join academic_years Y on F.academic_year_id = Y.id
    Inner Join semesters K on F.semester_id = K.id
    where  C.currentyear = #{yearId}   and C.category_id = F.id and F.organization_id = #{@organization_id} and C.examtype_id = #{examtype_id} and F.course_id = #{courseId} and F.department_id = #{departmentId} and F.academic_year_id = #{acadyear}
     ) A
    WHERE Pass=0
    GROUP BY courseId,coursename, department_id,departmentname,year_id,yearname,semester_id,semestername,currentyear) B
    ON A.courseId= B.courseId AND A.department_id= B.department_id AND A.year_id=B.year_id AND A.semester_id= B.semester_id AND A.currentyear = B.currentyear"
    
    @allYears = ExamResult.find_by_sql(semester)
  end
  
  def pass_fail
    @organization_id = Setting.find(1).organization_id
    @c = Category.where(['organization_id = ?', @organization_id])
    category_id = params[:examCategory].to_i
    @category_id = params[:examCategory].to_i
    
    examId = params[:examId].to_i
    @examId = params[:examId].to_i
    passFail = params[:passfail]
    @passFail = params[:passfail]
    academicYear = params[:academicYear].to_i
    @academicYear = params[:academicYear].to_i
    examtype = params[:examtype].to_i
    @examtype = params[:examtype].to_i

    @yrs = Array.new(10){|i| Date.current.year-i}
    @status = [[t('reports.passed'),'p'],[t('reports.failed'),'f']]
    @examTypes = Examtype.where(['organization_id = ?', @organization_id])
    @exams = []#Exam.where(['organization_id = ?', @organization_id])

    if @organization_id == 1
      if category_id != 0 and passFail == "All"
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as section,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
        
      @allYears = ExamResult.find_by_sql(status)
      
      else
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as section,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
        @allYears = ExamResult.find_by_sql(status)
      end
    end

    if @organization_id == 2
      if category_id != 0 and passFail == "All"
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as department,S.name as Exam,C.currentyear as AcademicYear,A.name as Currentyear,P.name as semester,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status;"
        
      @allYears = ExamResult.find_by_sql(status)
      
      else
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as department,S.name as Exam,C.currentyear as AcademicYear,A.name as Currentyear,P.name as semester,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status;"
        @allYears = ExamResult.find_by_sql(status)
      end
    end
   
     if @organization_id == 3 or @organization_id == 4
      if category_id != 0 and passFail == "All"
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as department,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
      @allYears = ExamResult.find_by_sql(status)
      
      else
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,N.name as department,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
        @allYears = ExamResult.find_by_sql(status)
      end
    end
    
  end
  
  def fetchExam
      @examNames = []
        categoryId = params[:categoryId].to_i
      year = params[:year].to_i
      examType = params[:examType].to_i
      
    @c = Categoryexam.where(['category_id = ? and currentyear = ? and examtype_id = ?',categoryId,year,examType])
    @c.each do|c|
      exam = Exam.find_by_id(c.exam_id)
      @examNames << exam
    end
    
    render :json => {:examNames=>@examNames}  
      
  end
  
  def generatePassfail
    @organization_id = Setting.find(1).organization_id
    category_id = params[:category_id].to_i
    examId = params[:exam_id].to_i
    passFail = params[:passfail]
    academicYear = params[:academicyear].to_i
    examtype = params[:examtype].to_i
    
    if @organization_id == 1

    if passFail == 'All'
       status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,M.name as course, N.name as section,Y.name as examtype,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"       
        @allYears = ExamResult.find_by_sql(status)
        
            @allYears.each do|r|
             @academicyear = r.AcademicYear.to_s
              @course = r.course
              @section = r.section
              @examname = r.Exam
              @examtype = r.examtype
            end
        
        if params[:pdf].to_i == 1
              pdftable = Prawn::Document.new              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.class') + ": " + @course) 
              pdftable.text(t('org.section') + ": " + @section)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)     
              
              pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"passfail.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
              @outfile = "passfail" + ".csv"
              @infile = ""
                csv_data = CSV::Writer.generate(@infile) do |csv|
                  
               csv << [
               t('exam.name') + ": " "#{@examname}",
               t('org.class') + ": " "#{@course}",
              t('org.section') + ": " "#{@section}",  
              t('general.acedemic_yr') + ": " "#{@academicyear}",
              t('exam.exam_type') + ": " "#{@examtype}"
              ] 
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),
                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                  end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}"
        end  
    else
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,M.name as course, N.name as section,Y.name as examtype,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
      
      @allYears = ExamResult.find_by_sql(status)
      
          @allYears.each do|r|
              @academicyear = r.AcademicYear.to_s
              @course = r.course
              @section = r.section
              @examname = r.Exam
              @examtype = r.examtype
          end
          
        if params[:pdf].to_i == 1
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.class') + ": " + @course) 
              pdftable.text(t('org.section') + ": " + @section)
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
              
              pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"passfail.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
               @outfile = "passfail" + ".csv"
               @infile = ""
                csv_data = CSV::Writer.generate(@infile) do |csv|
                  
               csv << [
               t('exam.name') + ": " "#{@examname}",
               t('org.class') + ": " "#{@course}",
              t('org.section') + ": " "#{@section}",
              
              t('general.acedemic_yr') + ": " "#{@academicyear}",
              t('exam.exam_type') + ": " "#{@examtype}"
              ]
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),
                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}"  
        end  
    end
    end
    
    if @organization_id == 2
    if passFail == 'All'
       
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,A.name as Currentyear,P.name as semester,E.score, E.percent,Q.attempt,E.status,M.name as course, N.name as department, O.name as academicYear, P.name as semester,Y.name as examtype,E.result_pending
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
        Inner Join academic_years O on F.academic_year_id = O.id
        Inner Join semesters P on F.semester_id = P.id
        Inner Join examtypes Y on C.examtype_id = Y.id
    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
        
        @allYears = ExamResult.find_by_sql(status)
        
        @allYears.each do|r|
          @academicyear = r.AcademicYear.to_s
        @course = r.course
        @department = r.department
        @year = r.academicYear
        @semester = r.semester
        @examname = r.Exam
        @examtype = r.examtype
        end
        
        if params[:pdf].to_i == 1
            pdftable = Prawn::Document.new
               img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.course') + ": " + @course) 
                pdftable.text(t('org.dept') + ": " + @department)
                pdftable.text(t('org.year') + ": " + @year + " year")
                pdftable.text(t('org.semester') + ": " + @semester + " semester")
                pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
                pdftable.text(t('exam.exam_type') + ": " + @examtype)
                            
              pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"passfail.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
            @outfile = "passfail" + ".csv"
            @infile = ""
            csv_data = CSV::Writer.generate(@infile) do |csv|
                  
             csv << [
             t('exam.name') + ": " "#{@examname}",
            t('org.course') + ": " "#{@course}",
            t('org.dept') + ": " "#{@department}",
            t('org.year') + ": " "#{@year}",
            t('org.semester') + ": " "#{@semester}",
            t('general.acedemic_yr') + ": " "#{@academicyear}",
            t('exam.exam_type') + ": " "#{@examtype}"                        
            ]
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                  end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}"
        end   
    else      
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,A.name as Currentyear,P.name as semester,E.score, E.percent,Q.attempt,E.status,M.name as course, N.name as department, O.name as academicYear, P.name as semester,Y.name as examtype,E.result_pending
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
        Inner Join academic_years O on F.academic_year_id = O.id
        Inner Join semesters P on F.semester_id = P.id
        Inner Join examtypes Y on C.examtype_id = Y.id    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
      
      @allYears = ExamResult.find_by_sql(status)
      
       @allYears.each do|r|
         @academicyear = r.AcademicYear.to_s
        @course = r.course
        @department = r.department
        @year = r.academicYear
        @semester = r.semester
        @examname = r.Exam
        @examtype = r.examtype
       end
      
        if params[:pdf].to_i == 1
             pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100 
              
              pdftable.move_down(60)
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.course') + ": " + @course) 
              pdftable.text(t('org.dept') + ": " + @department)
              pdftable.text(t('org.year') + ": " + @year + " year")
              pdftable.text(t('org.semester') + ": " + @semester + " semester")
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
                           
              pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"default_filename.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
                @outfile = "passfail-" + ".csv"
                @infile = ""
                csv_data = CSV::Writer.generate(@infile) do |csv|
                  
             csv << [
             t('exam.name') + ": " "#{@examname}",
            t('org.course') + ": " "#{@course}",
            t('org.dept') + ": " "#{@department}",
            t('org.year') + ": " "#{@year}",
            t('org.semester') + ": " "#{@semester}",
            t('general.acedemic_yr') + ": " "#{@academicyear}",
            t('exam.exam_type') + ": " "#{@examtype}"                        
            ]
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}" 
        end    
    end    
    end
     
    
    if @organization_id == 3 or @organization_id == 4
    if passFail == 'All'
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,N.name as department,Y.name as examtype,E.result_pending
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
    
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype}
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
         
        @allYears = ExamResult.find_by_sql(status)
        
        @allYears.each do|r|          
        @academicyear = r.AcademicYear.to_s
        @department = r.department
        @examname = r.Exam
        @examtype = r.examtype
        end
        
        if params[:pdf].to_i == 1
              pdftable = Prawn::Document.new
              
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              pdftable.move_down(60)
              
               pdftable.text(t('exam.name') + ": " + @examname)   
               pdftable.text(t('org.dept') + ": " + @department) 
               pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
               pdftable.text(t('exam.exam_type') + ": " + @examtype)
                           
 
              pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"passfail.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
              @outfile = "passfail" + ".csv"
                              @infile = ""
                csv_data = CSV::Writer.generate(@infile) do |csv|
                  
                  csv << [
                  t('exam.name') + ": " "#{@examname}",
                  t('org.dept') + ": " "#{@department}",
                  t('general.acedemic_yr') + ": " "#{@academicyear}",
                  t('exam.exam_type') + ": " "#{@examtype}",                                    
                  ]
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                  end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}"
        end

   
    else      
        status = "SELECT S.id,E.id, D.id,C.id ,U.name,U.login,U.is_temp_examinee as tempexaminee,S.name as Exam,C.currentyear as AcademicYear,E.score, E.percent,Q.attempt,E.status,N.name as department,Y.name as examtype,E.result_pending
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
        where  C.currentyear = #{academicYear} and C.category_id = F.id and F.id = #{category_id} and S.id = #{examId} and Y.id = #{examtype} and E.status = '#{passFail}'
        group by S.id,U.name,Q.attempt,E.score,E.percent,E.status"
      
      @allYears = ExamResult.find_by_sql(status)
      
       @allYears.each do|r|
         @academicyear = r.AcademicYear.to_s
        @department = r.department
        @examname = r.Exam
        @examtype = r.examtype
       end
       
        if params[:pdf].to_i == 1
          pdftable = Prawn::Document.new
             
              img = "#{Rails.root}/public/images/virtualx_logo.jpg"
              pdftable.image img, :at => [350,700], :width => 100
              
              pdftable.move_down(60)              
              
              pdftable.text(t('exam.name') + ": " + @examname)
              pdftable.text(t('org.dept') + ": " + @department) 
              pdftable.text(t('general.acedemic_yr') + ": " + @academicyear)
              pdftable.text(t('exam.exam_type') + ": " + @examtype)
                               
                pdftable.table([[t('user.examinee'),t('exam.mark_scored'),t('exam.percent'),t('general.status')]],
                :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["d5d5d5"])
              
              @allYears.each do|r|
              pdftable.table([["#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}","#{r.score.to_f.round(2)}","#{r.percent.to_f.round(2)}",r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"]],
              :column_widths => {0 => 195, 1 => 80, 2 => 70, 3 => 70, 4 => 86, }, :row_colors => ["ffffff"]
               )
              end
            send_data pdftable.render, :filename=>"default_filename.pdf", :type=>"application/pdf"
        end
        
        if params[:csv].to_i == 1
                @outfile = "passfail-" + ".csv"
                @infile = ""
                csv_data = CSV::Writer.generate(@infile) do |csv|
                  
                  csv << [
                  t('exam.name') + ": " "#{@examname}",
                  t('org.dept') + ": " "#{@department}",
                  t('general.acedemic_yr') + ": " "#{@academicyear}",
                  t('exam.exam_type') + ": " "#{@examtype}",                                    
                  ]
                  
                  csv << [
                  t('user.examinee'),
                  t('exam.mark_scored'),
                  t('exam.percent'),
                  t('general.status'),                 
                  ]
                  
                  @allYears.each do|r|
                     csv << [
                       "#{r.tempexaminee}" == '1' ? "#{r.login}" : "#{r.name}",
                       "#{r.score.to_f.round(2)}",
                       "#{r.percent.to_f.round(2)}",
                       r.result_pending.to_i == 0 ? ("#{r.status}" == "p" ? t('reports.pass') : t('reports.fail')) : "pending"
                     ]
                  end
          
                end
               send_data @infile,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}" 
        end    
    end    
    end    
  end  
end
