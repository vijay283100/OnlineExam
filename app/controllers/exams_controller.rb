class ExamsController < ApplicationController
  filter_access_to :all
  
  def index
    @organization_id = Setting.find(:first).organization_id
    @exams = Exam.where(['organization_id = ?',@organization_id]).order('created_at desc').paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @users = User.find_all_by_role_id_and_is_approved(4,1)
    @exam = Exam.new
  end
  
  def create
    @organization_id = Setting.find(:first).organization_id
    @exam = Exam.new(params[:exam])
    @time = params[:exam][:total_time]

    @time = []
    @time = params[:exam][:total_time]
    @exam.time_hour =  @time[1,2].to_i
    @exam.time_min= @time[3,4].to_i
    
    @exam.organization_id = @organization_id
    if @exam.save 
      flash[:success] = t('flash_success.exam_shedule')
    end
    redirect_to :action=>"index", :controller=>"exams"

  end
  
  def edit
     @exam = Exam.find_by_id(params[:id])
     
     @examQuestions = Examquestion.where(["exam_id = ?", params[:id].to_i])
     @fetchQuestions = 0
     @examQuestions.each do|eq|
        @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
     end
     @fetchQ = @fetchQuestions.to_i
     @examMark = @exam.total_mark 
     
    exam = @exam.id
    sql = "SELECT U.name, U.id as user_id, C.id as categoryexam_id, D.id as categoryuser_id, D.currentyear as year
          FROM       categoryexamusers Q 
          Inner Join categoryusers D on Q.categoryuser_id = D.id
          Inner Join categoryexams C on Q.categoryexam_id = C.id
          Inner Join users U on D.user_id = U.id
          Inner Join exams S on C.exam_id = S.id
    where S.id = #{exam};"
    
    @examUsers = User.find_by_sql(sql)
    @examQuestions = @exam.questions
  end
  
  def update
    @exam = Exam.find(params[:id].to_i)

     @total_mark = params[:exam][:total_mark].to_i
     @examQuestions = Examquestion.where(["exam_id = ?", params[:id].to_i])
     @fetchQuestions = 0
     @examQuestions.each do|eq|
         @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
     end

     if @total_mark > @fetchQuestions
       @exam.start_exam = 0
     else
       @exam.start_exam = 1
     end

    @time = []
    @time = params[:exam][:total_time]
    @exam.time_hour =  @time[1,2].to_i
    @exam.time_min= @time[3,4].to_i
    if @exam.update_attributes(params[:exam])
      flash[:success] = t('flash_success.exam_details')
      redirect_to :action=>"index", :controller=>"exams"
    end
    
  end
  
  def destroy
    @exam = Exam.find(params[:id])
    examquestions = Examquestion.where(["exam_id = ?",@exam.id])
    categoryexams = Categoryexam.where(["exam_id = ?",@exam.id])
    if examquestions.empty? and examquestions.empty? #and examusers.empty?
      @exam.destroy
      flash[:success] = t('flash_success.exam_deleted')
      respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
      end
    else
      flash[:success] = t('flash_notice.exam_cant')
      redirect_to :back
    end
    

  end
  
  def deleteExamQuestion
    @examQuestion = Examquestion.where(["exam_id = ? and question_id = ?", params[:exam_id],params[:question_id]]) 
    @examQuestion = Examquestion.find_by_id(@examQuestion.first.id) 
    @examQuestion.destroy
    
    @exam = Exam.find_by_id(params[:exam_id].to_i)
    @exam.start_exam = 0
    @exam.save
    @examQuestions = Examquestion.where(["exam_id = ?", params[:exam_id]])
     @fetchQuestions = 0
     @examQuestions.each do|eq|
       @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
     end         
    flash[:success] = t('flash_success.ques_from_exam')
    redirect_to :back
  end
  
  def deleteExamUser
    categoryexamuser = Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(params[:categoryuser_id],params[:categoryexam_id])
    examresult = ExamResult.find_by_categoryuser_id_and_categoryexam_id(params[:categoryuser_id],params[:categoryexam_id])
    if examresult == nil
    categoryexamuser.destroy
    flash[:success] = t('flash_success.examinee_from_exam')
    else
    flash[:notice] = t('flash_notice.examinee_from_exam_cant')
    end
    redirect_to :back
  end
  
  def scheduleExam
    @organization_id = Setting.find(:first).organization_id
    @exam = Exam.new
    @subjects = Subject.where(['organization_id = ?',@organization_id])
  end
  
  def getMark
    examId = params[:exam_id]
    @exam = Exam.find_by_id(examId.to_i)
    
    @totalMark = @exam.total_mark
    @examQuestions = Examquestion.where(["exam_id = ?", examId.to_i])
     @fetchQuestions = 0
     @examQuestions.each do|eq|
       @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
     end
     
    @taken = taken(examId.to_i) 
    
    unless @totalMark == nil
      render :json =>{:data=> @totalMark, :exam_id => @exam.id, :mark_assigned => @fetchQuestions, :taken=>@taken}
    else
      render :text => false
    end
  end
  
  def taken(e_id)
    sql = "SELECT A.id,Count(IFNULL(has_attended,0)) AS examTaken FROM 
    categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
    Inner Join exams E on B.exam_id = E.id
    Where E.id = #{e_id.to_i} and A.has_attended = 1
    group by  A.id;"

    @hasAttended = Exam.find_by_sql(sql)
    @hasAttended.each do|h|
      @attendedCount = h.examTaken
    end
    if @attendedCount.to_i == 0
      return 0
    else
      return 1
    end
    
  end
  
  
  def selectQuestion
    
    @evaluation_type = [["Manual","1"]]
    
    @pageCollect = params[:pageLength].to_i
    if @pageCollect == 0
      @pagelength = 10
    else
      @pagelength = params[:pageLength].to_i
    end   
    
    @taken = taken(params[:examname].to_i)

    @flag = params[:flag]
    @organization_id = Setting.find(:first).organization_id
    @yrs = Array.new(10){|i| Date.current.year-i}
    @nms = [2011,2010,2009]
    @examTypes = Examtype.where(['organization_id = ?',@organization_id])
    @categories = Category.find(:all, :conditions=>["organization_id = ?", @organization_id])
    @category_subject = Categorysubject.find(:all)
    @examNames = []
    @fetchQuestions = params[:fectchmark].to_i
    @categoryId = params[:categoryId].to_i
    @academicYear = params[:academicYear].to_i
    @examtypeName = params[:et_name].to_i
    @examMark = params[:examMark].to_i
    @markAssigned = params[:markAssigned].to_i
    @selectedExamname = params[:examname].to_i
    @questionType = params[:question_type].to_i
    @categoryType = params[:category_type].to_i

    @c = Categoryexam.where(['category_id = ? and currentyear = ? and examtype_id = ?',@categoryId,params[:academicYear].to_i, params[:et_name].to_i])
    @c.each do|c|
      exam = Exam.find_by_id(c.exam_id)
      @examNames << exam
    end
     
    @question_types = QuestionType.where(["id != ? and id != ?", 7,8])
    if current_user.role_id == Admin or current_user.role_id == Examiner
      if params[:question_type].to_i > 0
      @question_type_id = params[:question_type]
      @category_type = params[:category_type]
      @questions = Question.where(["question_type_id = ? and categorysubject_id = ? and (parent_id IS NULL or parent_id = ?) and is_published = ?", @question_type_id,@category_type,0,true]).paginate(:page => params[:page], :per_page => @pagelength) 
      @question_type = QuestionType.find(params[:question_type].to_i)
      @question_type_name = @question_type.name
      elsif params[:question_type].to_i == 0 and params[:category_type].to_i == 0
       @questions = Question.where(["categorysubject_id = ? and (parent_id IS NULL or parent_id = ?) and is_published = ? and question_type_id != ? and question_type_id != ?", 0,0,true,7,8]).paginate(:page => params[:page], :per_page => @pagelength) 
      elsif params[:question_type].to_i == 0 and params[:category_type].to_i >= 1
       @questions = Question.where(["categorysubject_id = ? and (parent_id IS NULL or parent_id = ?) and is_published = ? and question_type_id != ? and question_type_id != ?", params[:category_type].to_i,0,true,7,8]).paginate(:page => params[:page],:per_page => @pagelength) 
      else
       @questions = Question.where(["(parent_id IS NULL or parent_id = ?) and is_published = ? ",0,true]).order("created_at desc").paginate(:page => params[:page], :per_page => @pagelength)
      end
    end
  end

  def fetchMark
        @assignQuestion = 0
    @examQuestions = Examquestion.where(["exam_id = ?", params[:examName].to_i])
     @fetchQuestions = 0
     @examQuestions.each do|eq|
       @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
     end
  end
  
  def assignQustions
    
    @fetchExam = Exam.find_by_id(params[:examName].to_i)
    @examMark = @fetchExam.total_mark

    @examId = params[:examName] 
    fetchMark
    
    unless params[:question] == nil
      @examName = Exam.find_by_id(params[:examName])
      questions = params[:question]
      
       questions.each do|question|
         @assignQuestion += Question.sum(:mark, :conditions=>["id = ?", question.to_i])
       end
       
       @markAssigned = @fetchQuestions + @assignQuestion
        @markDifference = @markAssigned - @examMark   

         if @markAssigned > @examMark
           #flash[:notice] = t('flash_notice.ques_mark_exceeding') @markDifference.to_i t('flash_notice.ques_mark_exceeding')
           flash[:notice] = "#{t('flash_notice.ques_mark_exceeding')} #{@markDifference.to_i}."
         else
             questions.each do|question|
             getQuestion = Question.find_by_id(question.to_i)
             @examName.questions << getQuestion
             @examName.save
             end 
            if @markAssigned == @examMark
              @fetchExam.start_exam = 1
              @fetchExam.save
              fetchMark
              flash[:success] = t('flash_success.no_more_ques')
            else
              fetchMark
              flash[:success] = t('flash_success.ques_added')
            end
         end
              
      allQuestions = @examName.questions
     
      @randQuestions = Randomquestion.new
      @randQuestions.question_set = []
      allQuestions.each do|q| 
        @randQuestions.question_set << q.id
      end
      @randQuestions.exam_id = params[:examName]
      
      @randQuestions.save

      
      unless params[:evaluationtype] == "" or params[:evaluationtype] == nil
      @exam = Exam.find_by_id(params[:examName].to_i)
     
      @exam.update_attributes(:manual_evaluation => params[:evaluationtype])
      end
      
     redirect_to :action=>"selectQuestion", :examMark =>@examMark, :fectchmark=>@fetchQuestions, :markAssigned=>@markAssigned, :examname => @fetchExam.id, :question_type => params[:question_type].to_i, :category_type => params[:category_type].to_i, :categoryId => params[:categoryId].to_i, :et_name => params[:et_name], :academicYear=>params[:academicYear], :examName=>params[:examName].to_i
    else
      flash[:notice] = t('flash_notice.select_ques')
      redirect_to :action=>"selectQuestion", :question_type => params[:question_type].to_i, :category_type => params[:category_type].to_i
    end
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        flash[:notice] = t('flash_notice.uncheck_ques')
        @markAssigned = @fetchQuestions
        redirect_to :action=>"selectQuestion", :examMark =>@examMark, :fectchmark=>@fetchQuestions, :markAssigned=>@markAssigned, :examname => @fetchExam.id, :question_type => params[:question_type].to_i, :category_type => params[:category_type].to_i, :categoryId => params[:categoryId].to_i, :et_name => params[:et_name], :academicYear=>params[:academicYear], :examName=>params[:examName].to_i
  end

  def selectExaminee
    @organization_id = Setting.find(:first).organization_id
    @flag = params[:flag]
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    unless @from_date == nil
    @examNames = Exam.where(['organization_id = ? and date(created_at) between (?) and (?)',@organization_id,@from_date,@to_date])
    else
    @examNames = []#Exam.where(['organization_id = ?',@organization_id])
    end
    
    
    
    @category_id = params[:examCategory].to_i
    @exam_id = params[:examName].to_i

    unless @exam_id == nil
    @c = Categoryexam.where(:exam_id => @exam_id).group('category_id,currentyear')
    end
    
    @category_id = params[:examCategory].to_i

      unless @category_id == 0      
        category_exam = Categoryexam.find_by_id(@category_id)#where(["id = ?",@category_id])
         @category_user = Categoryuser.where(["category_id = ? and currentyear = ?",category_exam.category_id,category_exam.currentyear]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)      
      end

  end
 
  def assignExaminees
   exam_category = params[:setExamcategory].to_i
   @categoryexam = Categoryexam.find_by_id(params[:setExamcategory].to_i)
   categoryuser = params[:examinee]
   @examName = Exam.find_by_id(@categoryexam.exam_id)
   @examId = Exam.find_by_id(@categoryexam.exam_id)
   checkQuestons = @examId.questions
   @questions_length = checkQuestons.length
  if @questions_length > 0

  categoryuser.each do|user|  
    @categoryuser = Categoryuser.find_by_id(user.to_i)   
    @getCategoryexamuser = Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(@categoryuser.id, @categoryexam.id)
   
   if @getCategoryexamuser == nil
     @categoryexamuser = Categoryexamuser.new

      @categoryexamuser.categoryexam_id = @categoryexam.id
      @categoryexamuser.categoryuser_id = @categoryuser.id
      @categoryexamuser.attempt = 1
      
       getExaminee = User.find_by_id(@categoryuser.user_id)
              
       @categoryexamuser.exam_date = @examName.exam_date
       @categoryexamuser.time_hour = @examName.time_hour
       @categoryexamuser.time_min = @examName.time_min
       @categoryexamuser.need_evaluation = 2
       @categoryexamuser.save
       
          if getExaminee.is_temp_examinee == 0
            UserMailer.examSchedule(@examName,getExaminee).deliver
          end
       
    elsif @getCategoryexamuser.categoryexam_id == @categoryexam.id
      @attempt = @getCategoryexamuser.attempt
      
      @getCategoryexamuser.update_attributes(:attempt => @attempt+1, :has_attended=>0, :is_confirmed=>0, :exam_date=>@examName.exam_date, :time_hour=>@examName.time_hour, :time_min=>@examName.time_min, :need_evaluation=>2)
         @examName = Exam.find_by_id(@categoryexam.exam_id)
         getExaminee = User.find_by_id(@categoryuser.user_id)
          if getExaminee.is_temp_examinee == 0
            UserMailer.examSchedule(@examName,getExaminee).deliver
          end
   else
     @categoryexamuser = Categoryexamuser.new

      @categoryexamuser.categoryexam_id = @categoryexam.id
      @categoryexamuser.categoryuser_id = @categoryuser.id
      @categoryexamuser.attempt = 1
      @categoryexamuser.save
   end
  
  end
    flash[:success] = t('flash_success.examinee_to_exam')
    redirect_to :action => :selectExaminee, :examCategory => exam_category, :examName => @examName.id
  else
    flash[:notice] = t('flash_notice.assing_ques_to_exam')
    redirect_to :action => :selectExaminee
  end
  end
  
  def previewExam
    @exam = Exam.find_by_id(params[:exam].to_i)
    exam = @exam.id
    sql = "SELECT U.name, D.currentyear as year, U.is_temp_examinee as temp_examinee
          FROM       categoryexamusers Q 
          Inner Join categoryusers D on Q.categoryuser_id = D.id
          Inner Join categoryexams C on Q.categoryexam_id = C.id
          Inner Join users U on D.user_id = U.id
          Inner Join exams S on C.exam_id = S.id
    where S.id = #{exam};" 

    @examinees = User.find_by_sql(sql)
    @questions = @exam.questions

  end
  
  def assignExam
    @organization_id = Setting.find(:first).organization_id
    @exam = Exam.new
    
    #-----------------------------------------------------
     @from_date = params[:from_date]
     @to_date = params[:to_date]
    
    unless @from_date == nil
    @exams = Exam.where(['organization_id = ? and date(created_at) between (?) and (?)',@organization_id,@from_date,@to_date])
    else
    @exams = []#Exam.where(['organization_id = ?',@organization_id])
    end
    #--------------------------------------------------------------

    @examTypes = Examtype.where(['organization_id = ?',@organization_id])
    @yrs = Array.new(10){|i| Date.current.year-i}
    
    @category_types = CategoryType.where(["organization_id=?", @organization_id.to_i]).sort { |x,y| x.sort_order <=> y.sort_order }
    
    @c = Category.find(:all, :conditions=>["organization_id = ?", @organization_id]).paginate(:page => params[:page], :per_page => 10)
  end

  def getExam
   @organization_id = Setting.find(:first).organization_id
     @from_date = params[:from_date]
     @to_date = params[:to_date]
    unless @from_date == nil
    @examNames = Exam.where(['organization_id = ? and date(updated_at) between (?) and (?)',@organization_id,@from_date,@to_date])
    else
    @exams = []#Exam.where(['organization_id = ?',@organization_id])
    end
    render :json => {:examNames=>@examNames}  
  end
  
  def groupExam
    @getExam = Exam.find_by_id(params[:exam][:id].to_i)
    @getexamType = Examtype.find_by_id(params[:exam][:name].to_i)
    @categories = params[:category]
    unless params[:category] == nil     
      @categories.each do|category|
        @categoryexams = Categoryexam.new
      @getCategory = Category.find_by_id(category.to_i)  
      @categoryexams.category_id = @getCategory.id
      @categoryexams.exam_id = @getExam.id
      @categoryexams.examtype_id = @getexamType.id
      @categoryexams.currentyear = params[:academicYear]
      @categoryexams.save
    end
    flash[:success] = t('flash_success.exam_to_category')
    redirect_to :back
    end
  end
  
    def updateMark
      examId = params[:exam_id]
      mark = params[:mark]
      
      sql = "SELECT A.id,Count(IFNULL(has_attended,0)) AS examTaken FROM 
      categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
      Inner Join exams E on B.exam_id = E.id
      Where E.id = #{examId.to_i} and A.has_attended = 1
      Group By A.id;"

      @hasAttended = Exam.find_by_sql(sql)
      @hasAttended.each do|h|
      @attendedCount = h.examTaken
    end

   if @attendedCount.to_i == 0
     @examQuestions = Examquestion.where(["exam_id = ?", examId.to_i])
       @fetchQuestions = 0
       @examQuestions.each do|eq|
         @fetchQuestions += Question.sum(:mark, :conditions=>["id = ?", eq.question_id])
       end

      @exam = Exam.find_by_id(params[:exam_id])
      unless @fetchQuestions > mark.to_i
        if @exam.update_attributes(:total_mark=>params[:mark])
          @examName = Exam.find_by_id(params[:exam_id])
          @examMark = @examName.total_mark
          markDifference = @examMark - @fetchQuestions
          if markDifference >= 1
          @exam.update_attributes(:start_exam=>0)  
          render :json => {:text=>true, :markDiff => markDifference}
          else
          @exam.update_attributes(:start_exam=>1)
          render :json => {:text=>false}
          end
        end
      else
        render :json => {:notUpdated=>true}
      end
    else
      render :json => {:hasAttended=>true}
    end
   end
  
   def listExamtypes
    @organization_id = Setting.find(:first).organization_id
    @examtypes = Examtype.where(['organization_id = ?', @organization_id]).order('created_at desc').paginate(:page => params[:page], :per_page => 10) 
   end

  def examtype
    examtype = Examtype.new
  end
  
  def create_examtype
    @organization_id = Setting.find(:first).organization_id
    examtypeName = params[:examType]
    @examtype = Examtype.new
    @examtype.name = examtypeName
    @examtype.organization_id = @organization_id
    if @examtype.save
    flash[:success] = t('flash_success.examtype_created')
    redirect_to :action=>"listExamtypes"
    else
    flash[:notice] = t('flash_notice.examtype_cant')
    redirect_to :action=>"listExamtypes"
    end
  end
  
  def editExamtype
    @examtype = Examtype.find(params[:examtype_id])
  end
  
  def updateExamtype
    @examtype = Examtype.find(params[:examtype_id].to_i)
    @examtype.name = params[:examtype_name]
    if @examtype.save
      flash[:success] = t('flash_success.examtype_updated')
      redirect_to :action=> :listExamtypes
    else
      redirect_to :action=> :listExamtypes
      flash[:notice] = t('flash_notice.examtype_exists')
    end
  end
  
    def deleteExamtype
    @examtype = Examtype.find(params[:examtype_id].to_i)
    categoryexam = Categoryexam.where(["examtype_id = ?", params[:examtype_id].to_i])

    if categoryexam.empty?
      if @examtype.destroy
       flash[:success] = t('flash_success.examtype_deleted')
       redirect_to :action=> :listExamtypes
      end
    else
      flash[:notice] = t('flash_notice.examtype_cant_del')
      redirect_to :action=> :listExamtypes
    end

    end

    def showEvaluationtype
      @questionTypes = []
      @questions = params[:questions]
      @questions.each do|q|
        @findQuestion = Question.find_by_id(q.to_i)
        @questionTypes << @findQuestion.question_type_id
      end

      if @questionTypes.include?(12)
        render :json => {:manual_eval=>true}
      else
        render :json => {:manual_eval=>false}
      end
      #@question = Question.find_by_id(params[:question].to_i)
      #if @question.question_type_id == 12
      #  render :json => {:manual_eval=>true}
      #end
    end
  
    def hideEvaluationtype
      @question = Question.find_by_id(params[:question].to_i)
      if @question.question_type_id == 12
        render :json => {:manual_eval=>true}
      end
    end
  
    def userStatus
        category_id = params[:examCategory].to_i    
        academicYear = params[:academicYear].to_i
        examtype = params[:examtype].to_i
        exam = params[:exam].to_i
        sql = "SELECT  distinct E.manual_evaluation as evaluation, U.name,U.login,U.is_temp_examinee as tempexaminee, U.id as user_id, D.category_id as categoryid, D.currentyear as academicyear, C.examtype_id as examtype, Q.id as categoryexamuser_id, Q.need_evaluation as need_evaluation 
            FROM       categoryexamusers Q 
            Inner Join categoryusers D on Q.categoryuser_id = D.id
            Inner Join categoryexams C on Q.categoryexam_id = C.id
            Inner Join exams E on C.exam_id = E.id
            Inner Join users U on D.user_id = U.id
            where C.category_id= #{category_id}    and D.currentyear = #{academicYear} and C.examtype_id = #{examtype} and E.id = #{exam};" 
            @category_user = Categoryuser.find_by_sql(sql)
       
    end
    
    def evaluate
      @organization_id = Setting.find(:first).organization_id
      
      if current_user.role_id == 1 or current_user.role_id == 2
        @c = Category.where(['organization_id = ?',@organization_id])
        @yrs = Array.new(10){|i| Date.current.year-i}
        @examTypes = Examtype.where(['organization_id = ?',@organization_id])
        @exam = [] 
      elsif current_user.role_id == 3
        
        #@evaluatorExams = current_user.exams
        user_id = current_user.id
       #@evaluatorExams = Categoryexam.find(:all, :joins=> "INNER JOIN evaluate_exams ON evaluate_exams.exam_id = categoryexams.exam_id INNER JOIN evaluate_exams ON evaluate_exams.user_id = users.id AND evaluate_exams.user_id = #{@user_id}")
      
            #sql = "SELECT C.id as category_id
            sql = "SELECT distinct D.id as category_id
            FROM  evaluate_exams E 
            Inner Join categoryexams C on E.exam_id = C.exam_id
            Inner Join users U on E.user_id = U.id
            Inner Join categories D on D.id= C.category_id
            where U.id= #{user_id};" 
            @evaluatorExams = EvaluateExam.find_by_sql(sql)
        
        @c = Category.where(['organization_id = ?',@organization_id])
        @yrs = Array.new(10){|i| Date.current.year-i}
        @examTypes = Examtype.where(['organization_id = ?',@organization_id])
        @exam = []
      end

      
      @category_id = params[:examCategory].to_i
      
      
       category_id = params[:examCategory].to_i
       academicYear = params[:academicYear].to_i
       @academicYear = params[:academicYear].to_i
       
       examtype = params[:examtype].to_i
       @examtype = params[:examtype].to_i
       exam = params[:exam].to_i
       @examname = params[:exam].to_i
       
       @flag = params[:flag]
      unless @category_id == 0 
      userStatus
      end
      
      if current_user.role_id == 3
       @evaluator = EvaluateExam.find_by_user_id_and_exam_id(current_user.id,@examname) 
           unless @flag == 'eval'
             unless @evaluator == nil
                unless @category_user == nil or @category_user.empty?
                  @category_user.each do|exam|
                   @manual = exam.evaluation
                  end
                end
              else
                @notallowed = "n"
             end
          end
      elsif current_user.role_id == 1 or current_user.role_id == 2
        unless @category_user == nil or @category_user.empty?
         @category_user.each do|exam|
           @manual = exam.evaluation
         end
        end
      end
    
    
      unless params[:examinee] == nil
        @ques = params[:examinee]
        categoryexamuser = Categoryexamuser.find_by_id(params[:examinee].to_i)
        @examResult = ExamResult.find_by_categoryexam_id_and_categoryuser_id_and_attempt(categoryexamuser.categoryexam_id,categoryexamuser.categoryuser_id,categoryexamuser.attempt)
        
        unless @examResult == nil
        @categoryexam = Categoryexam.find_by_id(categoryexamuser.categoryexam_id)
        @categoryuser = Categoryuser.find_by_id(categoryexamuser.categoryuser_id)
        @attempt = categoryexamuser.attempt
        @exam = Exam.find_by_id(@categoryexam.exam_id)
        questions = @exam.questions
        
        #-------------mark-----------------------
          evaluationContent = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ?", @categoryexam.id,@categoryuser.id,@attempt])        
          tot = []
          evaluationContent.each do|e|
            tot << e.answer_mark unless e.answer_mark == nil
            @mark_secured = tot.inject(:+)
          end
          tot.clear
        #----------------------------------------
        
        @page_no = params[:page]
        @descriptive = @exam.questions.find(:all, :conditions =>["question_type_id LIKE ?", 12] ).paginate(:page => params[:page], :per_page => 1)
        end
      end
      
      
      #-----------------------Manual Evaluation--------------------------------
      
        unless params[:evaluate] == nil
         
        evaluation = Evaluation.find_by_id(params[:evaluate].to_i)
        evaluation.update_attributes(:question_mark => params[:question_mark].to_i,:answer_mark => params[:answer_mark].to_f, :evaluate=>0)
        @manualflag = "m"
        end
      #-------------------------------------------------------
      
      
      #-------------------Complete Evaluation------------------------
      
      if params[:finish] == 'f'
       
      @evaluation = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ? and evaluate = ?",params[:categoryexam].to_i,params[:categoryuser].to_i,params[:attempt].to_i,1])
      if @evaluation.empty?
        calculateScore
        userStatus
      @examComplete = params[:finish]
      else
      @examComplete = 'nf'
      end

      end
      #--------------------------------------------------------------
      
    end
  
    def getExamQuestions
      categoryexamuser = Categoryexamuser.find_by_id(params[:ceu].to_i)
      categoryexam = Categoryexam.find_by_id(categoryexamuser.categoryexam_id)
      categoryuser = Categoryuser.find_by_id(categoryexamuser.categoryuser_id)
      exam = Exam.find_by_id(categoryexam.exam_id)
      questions = exam.questions
      #questions = exam.questions.paginate :per_page => 5, :conditions => ["question_type_id LIKE ?", 12] 
      @descriptive = []
      questions.each do|q|
        if q.question_type_id == 12
          @descriptive << q
        end
      end
      
      unless @descriptive.empty?#@question.question_type_id == 12
        render :json => {:question=>true}
      else
        render :json => {:question=>false}
      end
    end
    
    
    def manualEvaluation     
      evaluation = Evaluation.find_by_id(params[:evaluate].to_i)
      
      if evaluation.update_attributes(:question_mark => params[:question_mark].to_i,:answer_mark => params[:answer_mark].to_f, :evaluate=>0)
        render :json => {:question=>true}
      end
    end
  
    def finishEvaluation
      @evaluation = Evaluation.where(["categoryexam_id = ? and categoryuser_id = ? and attempt = ? and evaluate = ?",params[:categoryexam].to_i,params[:categoryuser].to_i,params[:attempt].to_i,1])
      if @evaluation.empty?
        calculateScore
        render :json => {:evaluated=>true}
      else
        render :json => {:need_evaluation=>true}
      end
    end
  
  def calculateScore

    categoryExam = params[:categoryexam].to_i
    categoryUser = params[:categoryuser].to_i
    attempt = params[:attempt].to_i
    
   @categoryexamuser = Categoryexamuser.find_by_categoryexam_id_and_categoryuser_id_and_attempt(categoryExam,categoryUser,attempt)
   @examResult = ExamResult.find_by_categoryexam_id_and_categoryuser_id_and_attempt(categoryExam,categoryUser,attempt)
   
    sql = "SELECT F.id,S.id,S.name as examname,S.pass_mark as passmark,E.attempt,S.total_mark,Sum(answer_mark) As marks,(Sum(answer_mark) * 100)/S.total_mark as percentage
    From evaluations E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id    
    where C.id = #{categoryExam} and D.id = #{categoryUser} and E.attempt = #{attempt}   
    Group By F.id,S.id,S.name,E.attempt,S.total_mark;"
       @exam = Evaluation.find_by_sql(sql)
        @exam.each do|e|
          @percentage =  "#{e.percentage.to_f.round(1)}"
          passmark = "#{e.passmark.to_f}"
          @score = "#{e.marks}"
          if @percentage.to_f >= passmark.to_f or @percentage.to_f >= 100
             @status = 'p'
          else
           @status = 'f'
          end
        end        
      @examResult.update_attributes(:score=>@score,:status=>@status,:percent=>@percentage,:result_pending=>0)
      @categoryexamuser.update_attributes(:need_evaluation=>0,:status=>@status)
  end  
  
  def getCategoryexams
      category_id = params[:category_id].to_i
      examtype_id = params[:examtype_id].to_i
      academicYear = params[:year].to_i
      @exams = Exam.find(:all, :joins=> "INNER JOIN categoryexams ON categoryexams.exam_id = exams.id AND categoryexams.category_id = #{category_id} AND categoryexams.examtype_id = #{examtype_id} AND categoryexams.currentyear = #{academicYear}")
      if @exams.empty?
        @exams = []
      end
     render :json => {:examNames=>@exams} 
  end
  
  def getEvaluator
        @organization_id = Setting.find(:first).organization_id
    @flag = params[:flag]
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    unless @from_date == nil
    @examNames = Exam.where(['organization_id = ? and date(created_at) between (?) and (?)',@organization_id,@from_date,@to_date])
    else
    @examNames = []#Exam.where(['organization_id = ?',@organization_id])
    end
    
    @exam_id = params[:examName].to_i

    unless @exam_id == nil
    #@c = Categoryexam.where(:exam_id => @exam_id).group('category_id,currentyear')
    @c = Category.where(["organization_id = ?", @organization_id])
    end
    
    @category_id = params[:examCategory].to_i
    category_id = params[:examCategory].to_i
      unless @category_id == 0 
        
        category_exam = Categoryexam.find_by_id(@category_id)
         #@category_user = Categoryuser.where(["category_id = ? and currentyear = ?",category_exam.category_id,category_exam.currentyear]).order("created_at desc").paginate(:page => params[:page], :per_page => 10)      
         sql = "SELECT  U.name as userName, U.id as userId, B.category_id as categoryId, S.name as subjectName 
            FROM       subjectusers A 
            Inner Join categorysubjects B on B.id = A.categorysubject_id
            Inner Join users U on U.id = A.user_id
            Inner Join subjects S on S.id = B.subject_id           
            where B.category_id= #{category_id};" 
            @category_user = Categoryuser.find_by_sql(sql)
 
      end

  end

  def assignEvaluator
    @users = params[:examinee] 
    @exam = params[:examId].to_i
    
    @users.each do|user|
      @evaluator = EvaluateExam.new
      @evaluator.user_id = user.to_i
      @evaluator.exam_id = @exam
      @evaluator.save
    end
    flash[:success] = "Evaluator has been assigned"
    redirect_to :action=>"getEvaluator", :controller=>"exams"
  end
  
  
  def evaluator
      @organization_id = Setting.find(:first).organization_id
      @c = Category.where(['organization_id = ?',@organization_id])
      @category_id = params[:examCategory].to_i
      @yrs = Array.new(10){|i| Date.current.year-i}
      @examTypes = Examtype.where(['organization_id = ?',@organization_id])
       category_id = params[:examCategory].to_i
       academicYear = params[:academicYear].to_i
       @academicYear = params[:academicYear].to_i
       @exam = []
       examtype = params[:examtype].to_i
       @examtype = params[:examtype].to_i
       exam = params[:exam].to_i
       @examname = params[:exam].to_i

       if params[:delEvaluator].to_i == 1
         @flag = "d"
         delete_evaluator
       end

       if exam == 0
       @evaluators = User.where(["role_id = ?",3]).paginate(:page => params[:page], :per_page => 20)
       @nodelete = 1
       else

       @exam = Exam.find(params[:exam].to_i)
       @evaluators = @exam.users.find(:all).paginate(:page => params[:page], :per_page => 20)
       
       end
     
     
     
   end
  
   def delete_evaluator
     @examEvaluator = EvaluateExam.find_by_exam_id_and_user_id(params[:exam].to_i,params[:user_id].to_i)
     unless @examEvaluator == nil
      @examEvaluator.destroy
     end
    end
  
end
