class AttendExamsController < ApplicationController

  filter_access_to :all
  
  layout :choose_layout

  def choose_layout
    if action_name == 'index' or action_name == 'completedExams' or action_name == 'pendingExams'
      return 'application'
    elsif action_name == 'instruction' or action_name == 'examination' or action_name == 'examComplete'
      return 'examinationLayout'
    end
  end
  
  def index
     userId = User.find(current_user.id)  
     userId = userId.id

    @setting = Setting.find(:first)
    @setting = @setting.confirm_exam
    @current_time = Time.now()
    
    sql = "SELECT A.id,A.categoryexam_id,A.categoryuser_id,A.is_confirmed,A.has_attended,A.attempt,B.exam_id,A.time_hour,A.time_min,E.name,E.exam_code,A.exam_date,E.total_time,E.examstart_time,E.start_exam FROM categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
    Inner Join categoryusers C on A.categoryuser_id = C.id
    Inner Join users D on C.user_id = D.id
    Inner Join exams E on B.exam_id = E.id
    Where D.id = #{userId};"
    
    @exams_list = Categoryexamuser.find_by_sql(sql)
  end

  def completedExams
    @setting = Setting.find(:first)
    @setting = @setting.confirm_exam
    @current_time = Time.now()
    userId = User.find(current_user.id)  
    userId = userId.id
    sql = "SELECT A.id,A.categoryexam_id,A.categoryuser_id,A.is_confirmed,A.has_attended,A.attempt,B.exam_id,A.time_hour,A.time_min,E.name,E.exam_code,A.exam_date,E. total_time,E.examstart_time,E.start_exam FROM categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
    Inner Join categoryusers C on A.categoryuser_id = C.id
    Inner Join users D on C.user_id = D.id
    Inner Join exams E on B.exam_id = E.id
    Where D.id = #{userId} and A.has_attended = 1;"
    @exams_list = Categoryexamuser.find_by_sql(sql)
  end
  
  def pendingExams
    @setting = Setting.find(:first)
    @setting = @setting.confirm_exam
    @current_time = Time.now()
    userId = User.find(current_user.id)  
    userId = userId.id
    sql = "SELECT A.id,A.categoryexam_id,A.categoryuser_id,A.is_confirmed,A.has_attended,A.attempt,B.exam_id,A.time_hour,A.time_min,E.name,E.exam_code,A.exam_date,E. total_time,E.examstart_time,E.start_exam FROM categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
    Inner Join categoryusers C on A.categoryuser_id = C.id
    Inner Join users D on C.user_id = D.id
    Inner Join exams E on B.exam_id = E.id
    Where D.id = #{userId} and (A.is_confirmed = 0 or A.is_confirmed = 1) and A.has_attended = 0;"
    @exams_list = Categoryexamuser.find_by_sql(sql)
  end

  def confirm_exam
    @ce = Categoryexamuser.find_by_categoryexam_id_and_categoryuser_id(params[:categoryexam_id], params[:categoryuser_id])
    @ce.update_attributes(:is_confirmed=>1)
    flash[:success] = t('flash_success.exam_confirmed')
    redirect_to :back
  end
  
  def reject_exam
    @ce = Categoryexamuser.find_by_categoryexam_id_and_categoryuser_id(params[:categoryexam_id], params[:categoryuser_id])
    @ce.update_attributes(:is_confirmed=>2)
    flash[:success] = t('flash_success.exam_rejected')
    redirect_to :back
  end
  
  def instruction
    @hostname = Setting.find(:first).url
    @category_user = params[:categoryuser_id].to_i
    @category_exam = params[:categoryexam_id].to_i
    @exam_id = params[:exam_id].to_i
    @current_time = Time.now()
    @attempt = params[:attempt].to_i
    @exam = Exam.find_by_id(@exam_id)
    
     exam_hrs = @exam.exam_date.hour()
     exam_min = @exam.exam_date.min()
     dur_hrs = @exam.total_time.hour()
     dur_min = @exam.total_time.min()
    
     tot_hrs = exam_hrs + dur_hrs
     tot_min = exam_min + dur_min
    
    if tot_min >= 60
     hr_carry = tot_min/60
     tot_hrs = tot_hrs + hr_carry
     mns_diff = tot_min - 60
    end
    
    if tot_min < 60
     tot_hrs = tot_hrs 
     mns_diff = tot_min
    end
    
     if tot_hrs == 0 or tot_hrs == 1 or tot_hrs == 2 or tot_hrs == 3 or tot_hrs == 4 or tot_hrs == 5 or tot_hrs == 6 or tot_hrs == 7 or tot_hrs == 8 or tot_hrs == 9 
     tot_hrs = "0" + tot_hrs.to_s 
    end
    
     if mns_diff == 0 or mns_diff == 1 or mns_diff == 2 or mns_diff == 3 or mns_diff == 4 or mns_diff == 5 or mns_diff == 6 or mns_diff == 7 or mns_diff == 8 or mns_diff == 9 
     final_time = tot_hrs.to_s + ":0" + mns_diff.to_s
    else
     final_time = tot_hrs.to_s + ":" + mns_diff.to_s
    end
    
    if (final_time >= @current_time.strftime('%H:%M+1'))
    
    @categoryexamuser = Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(@category_user,@category_exam)
    @categoryexamuser.update_attributes(:has_attended=>1)
    allQuestions = @exam.questions
    
    @questions_length = allQuestions.length 
      randQuestion = []
      allQuestions.each do|a|
       randQuestion << a.id
      end
     shuffleQuestion = randQuestion.shuffle
      @categoryexamuser.update_attributes(:question_set=>shuffleQuestion,:has_attended=>1)
    else
      flash[:notice] = t('flash_notice.time_elapsed')
      redirect_to :action=>"examinee_dashboard", :controller=>"welcome"
    end
  end
  
  def examComplete
    categoryUser = params[:categoryuser_id].to_i
    categoryExam = params[:categoryexam_id].to_i
    @categoryUser = params[:categoryuser_id].to_i
    @categoryExam = params[:categoryexam_id].to_i

    sql = "SELECT E.name,E.exam_code,A.exam_date,A.time_hour,A.time_min,E. total_time,E.examstart_time FROM categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
    Inner Join categoryusers C on A.categoryuser_id = C.id
    Inner Join users D on C.user_id = D.id
    Inner Join exams E on B.exam_id = E.id
    Where A.categoryexam_id = #{categoryExam} and A.categoryuser_id = #{categoryUser};"
    
    @samp = Categoryexamuser.find_by_sql(sql)
      @samp.each do|exam|
      @exam_date = exam.exam_date
      @start_hour = exam.time_hour.to_i
      @start_min = exam.time_min.to_i
    end
    
    @t = params[:t].to_i
    @attempt = params[:attempt].to_i

  end
  
  def calculateScore
    
    categoryExam = params[:categoryexam_id].to_i
    categoryUser = params[:categoryuser_id].to_i
    attempt = params[:attempt].to_i
    
   @categoryexamuser = Categoryexamuser.find_by_categoryexam_id_and_categoryuser_id(categoryExam,categoryUser)
   
    user = current_user.id
    
    sql = "SELECT F.id,S.id,S.name as examname,E.attempt,S.total_mark,Sum(answer_mark) As marks,(Sum(answer_mark) * 100)/S.total_mark as percentage
    From evaluations E
    Inner Join categoryexams C on E.categoryexam_id = C.id
    Inner Join categoryusers D on E.categoryuser_id = D.id
    Inner Join categories F on C.category_id = F.id
    Inner Join exams S on C.exam_id = S.id
    Inner Join users U on D.user_id = U.id
    
    where U.id = #{user} and C.id = #{categoryExam} and D.id = #{categoryUser} and E.attempt = #{attempt}
    
    Group By F.id,S.id,S.name,E.attempt,S.total_mark;"

    @exam = Evaluation.find_by_sql(sql)

    unless @categoryexamuser.need_evaluation == 1
        @exam.each do|e|
          percentage =  "#{e.percentage.to_f.round(1)}"
          @examResult = ExamResult.new
          @examResult.categoryuser_id = categoryUser
          @examResult.categoryexam_id = categoryExam
          @examResult.attempt = attempt
          @examResult.score = "#{e.marks}"
          @examResult.total_mark = "#{e.total_mark}"
          @examResult.percent = "#{e.percentage.to_f.round(1)}"
          @examResult.examname= "#{e.examname}"
          @categoryexamuser = Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(categoryUser,categoryExam)
          if percentage.to_f >=40 or percentage.to_f >= 100
           @examResult.status = 'p'
           @categoryexamuser.status = 'p'
           @categoryexamuser.need_evaluation=0
          else
            @examResult.status = 'f'
            @categoryexamuser.status = 'f'
            @categoryexamuser.need_evaluation=0
          end
         @examResult.save
         @categoryexamuser.save
        end
    else
       @exam.each do|e|
         @examResult = ExamResult.new
         @examResult.categoryuser_id = categoryUser
         @examResult.categoryexam_id = categoryExam
         @examResult.attempt = attempt
         @examResult.total_mark = "#{e.total_mark}"
         @examResult.examname= "#{e.examname}"
         @examResult.result_pending= 1
         @examResult.save
       end
    end
    redirect_to :action=>"windowClose", :controller=>"attend_exams"
  end
  
  
  def examination
 
    if current_user

      @categoryUser = params[:categoryuser_id].to_i
      @categoryExam = params[:categoryexam_id].to_i
      categoryExam = params[:categoryexam_id].to_i
     
      @examAttended=Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(params[:categoryuser_id].to_i,params[:categoryexam_id].to_i)
      userQuestionset = @examAttended.question_set
      unless userQuestionset.empty?

      sql = "SELECT E.name,E.exam_code,A.exam_date,A.time_hour,A.time_min,E.total_time,E.examstart_time FROM categoryexamusers A Inner Join categoryexams B on A.categoryexam_id = B.id 
      Inner Join categoryusers C on A.categoryuser_id = C.id
      Inner Join users D on C.user_id = D.id
      Inner Join exams E on B.exam_id = E.id
      Where A.categoryexam_id = #{categoryExam} and A.categoryuser_id = #{@categoryUser};"      
      
       @samp = Categoryexamuser.find_by_sql(sql)
       
     @questions = []
     userQuestionset.each do |s|
       @questions << Question.find_by_id(s)
     end
   
      @attempt = params[:attempt].to_i
      @samp.each do|exam|
      @exam_date = exam.exam_date
      @start_hour = exam.time_hour.to_i
      @start_min = exam.time_min.to_i
      @total_time = exam.total_time
      end
      
      @questions_length = @questions.length
      question_hash = Hash.new
      q = 1
      
      for q in (q .. @questions_length)
        question_hash[q] = ""
      end
      
      i = 1
      @questions.each do|question|
        question_hash[i] = question
        i = i+1
      end
      
      @p = params[:t].to_i
      if @p < 1
        @t = 1
        @question = question_hash[@t]
      elsif @p == @questions_length + 1
        redirect_to :action=>"examComplete", :t => @p, :categoryuser_id => @categoryUser, :categoryexam_id=> @categoryExam, :attempt => @attempt
      else
        @t = params[:t].to_i
        @question = question_hash[@t]
      end
      
    else
      flash[:notice] = t('flash_notice.contact_admin')
      redirect_to :action=>"examinee_dashboard", :controller=>"welcome"
    end
    end
  end
  
  def evaluation
     @categoryUser = params[:categoryuser_id].to_i
     @categoryExam = params[:categoryexam_id].to_i
     
     @question_id = params[:question_id].to_i
     @attempt = params[:attempt].to_i

     @examUser = Categoryexamuser.find_by_categoryuser_id_and_categoryexam_id(@categoryUser,@categoryExam)
     @lastAttempt = @examUser.attempt
     @currentAttempt = @attempt
     
     #check for manual correction
     @ce = Categoryexam.find_by_id(params[:categoryexam_id].to_i)
     @is_manual = Exam.find_by_id(@ce.exam_id)
     #------------end-----------------
     
    if params[:question_type_id] == '6'
      
      unless params[:attended] == "true"
         @answer = params[:dropped].to_i
         dragDrop
         evaldragDrop
      else
         @alreadyAnswered = Evaluation.find_by_id(params[:evaluation_id].to_i)
         @answer = params[:dropped].to_i
                  
         unless @alreadyAnswered.answer_id == @answer
           @alreadyAnswered.destroy
           dragDrop
           evaldragDrop
         end
      end      
    end 
     
     
    if params[:question_type_id] == '1' or params[:question_type_id] == '4' or params[:question_type_id] == '5'
       
       unless params[:attended] == "true"
         @answer = params[:answer_id].to_i
         multipleChoice
         evalMultipleChoice
        else
         @alreadyAnswered = Evaluation.find_by_id(params[:evaluation_id].to_i)
         @answer = params[:answer_id].to_i
         
         unless @alreadyAnswered.answer_id == @answer
           @alreadyAnswered.destroy
           multipleChoice
           evalMultipleChoice
         end
       end
    end  
    
    if params[:question_type_id] =='2'
      @answer = params[:answer_id]
      @evaluation = params[:evaluation_id]
      
      @ans = []
      @answer.each do|a|
        @ans << a.to_i
      end
      
       if @evaluation == nil
            multipleSelection
            evalMultipleSelection
       else
           @eval = []
           @evaluation.each do|e|
           @alreadyAnswered = Evaluation.find_by_id(e.to_i)
           @eval << @alreadyAnswered.answer_id
           end
          
           unless @ans == @eval
           @evaluation.each do|e|
            @alreadyAnswered = Evaluation.find_by_id(e.to_i)
            @alreadyAnswered.destroy
            end
            multipleSelection
            evalMultipleSelection
           end
       end

    end
    
    if params[:question_type_id] == '3'

      @evaluation = params[:evaluation_id]
      if @evaluation == nil
        fillups        
      else
        Evaluation.update(params[:answer].keys, params[:answer].values)
        fillupEdit
      end
      
    end
    
    if params[:question_type_id] == '9'

      @answer = params[:answer_id]
      @evaluation = params[:evaluation_id]
      
      @ans = []
      @answer.each do|a|
        @ans << a.to_i
      end
      
       if @evaluation == nil
            imageBased
            eval_imageBased
       else
           @eval = []
           @evaluation.each do|e|
           @alreadyAnswered = Evaluation.find_by_id(e.to_i)
           @eval << @alreadyAnswered.answer_id
           end
          
           unless @ans == @eval
           @evaluation.each do|e|
            @alreadyAnswered = Evaluation.find_by_id(e.to_i)
            @alreadyAnswered.destroy
            end
            imageBased
            eval_imageBased
            end
       end

    end
    
    if params[:question_type_id] == '10'

      @answer = params[:answer_id]
      @evaluation = params[:evaluation_id]
      @current_answer = params[:current_answer_id]     
      
       if @evaluation == nil
            hrcl_ordering
            eval_hrcl
       else

           unless @evaluation == @current_answer
           @evaluation.each do|e|
            @alreadyAnswered = Evaluation.find_by_id(e.to_i)
            @alreadyAnswered.destroy
            end
            hrcl_ordering
            eval_hrcl
           end
       end
    end
    
    if params[:question_type_id] == '11'

      @answer = params[:answer_id]
      @evaluation = params[:evaluation_id]
      @current_answer = params[:current_answer_id]      
      
       if @evaluation == nil
            matching
            evalMatching
       else

           unless @evaluation == @current_answer
            @evaluation.each do|e|
            @alreadyAnswered = Evaluation.find_by_id(e.to_i)
            @alreadyAnswered.destroy
            end
            matching
            evalMatching
           end
       end

     end

    if params[:question_type_id] =='12' and @is_manual.manual_evaluation == 0
      @answer = params[:answer_name]
      @evaluation = params[:evaluation_id]
            
       if @evaluation == nil
            descriptive
            evalDescriptive
       else
           @alreadyAnswered = Evaluation.find_by_id(@evaluation.to_i)          
           #@alreadyAnswered = Evaluation.find_by_id(@evaluation.to_i)
           @alreadyAnswered.destroy
           descriptive
           evalDescriptive
       end
       
    elsif params[:question_type_id] =='12' and @is_manual.manual_evaluation == 1
      @evaluation = params[:evaluation_id]
      if @evaluation == nil
        @examUser.need_evaluation = 1
        @examUser.save
        descriptive
      else
         @alreadyAnswered = Evaluation.find_by_id(@evaluation.to_i)  
         @alreadyAnswered.destroy
         descriptive
      end
    end

    redirect_to :action=>"examination", :categoryuser_id => params[:categoryuser_id].to_i, :categoryexam_id => params[:categoryexam_id].to_i, :attempt=>@attempt, :t => params[:t].to_i
  end
  
  def dragDrop
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = @answer
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
  end
  
  
  def evaldragDrop
       
       @eval = Evaluation.find_by_categoryuser_id_and_categoryexam_id_and_question_id_and_attempt(@categoryUser,@categoryExam,@question_id,@attempt)
       
       @answers = Answer.find_by_question_id_and_is_answer(@question_id,1)
       @question = Question.find_by_id(@question_id)
       @answerCollection = []
       @evalCollection = []
       
        @evalCollection << @eval.answer_id
        @answerCollection << @answers.id
       
       if @answerCollection == @evalCollection
         @eval.question_mark = @question.mark
         @eval.answer_mark = @question.mark
         @eval.save
       else
         @eval.question_mark = @question.mark
         @eval.answer_mark = 0   
         @eval.save
       end
  end
  
  def multipleChoice
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = @answer
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
  end
  
  def evalMultipleChoice       
       @eval = Evaluation.find_by_categoryuser_id_and_categoryexam_id_and_question_id_and_attempt(@categoryUser,@categoryExam,@question_id,@attempt)
       @answers = Answer.find_by_question_id_and_is_answer(@question_id,1)
       @question = Question.find_by_id(@question_id)
       @answerCollection = []
       @evalCollection = []
       
        @evalCollection << @eval.answer_id
        @answerCollection << @answers.id
       
       if @answerCollection == @evalCollection
         @eval.question_mark = @question.mark
         @eval.answer_mark = @question.mark
         @eval.save
       else
         @eval.question_mark = @question.mark
         @eval.answer_mark = 0   
         @eval.save
       end
  end
  
  def multipleSelection
       @answer.each do|answer|        
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = answer.to_i
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
       end
  end
                                                                                                                                                              
  def evalMultipleSelection
       @eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id,@attempt])
       @answers = Answer.where(["question_id = ? and is_answer = ?", @question_id,1]) 
       @question = Question.find_by_id(@question_id)
       @question_mark = @question.mark
       
       @answerCollection = []
       @evalCollection = []
       
       @eval.each do |eval|
        @evalCollection << eval.answer_id
       end
     
       @answers.each do |answer|
         @answerCollection << answer.id
       end
       
       @evalLength = @answerCollection.length
       
       individualMark = @question_mark/@evalLength
       
      q = 0
      for q in (q ... @evalLength)
         puts @evalCollection[q].inspect
        if @answerCollection.include?(@evalCollection[q])

         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = individualMark
         @eval[q].save
        else
         unless @eval[q] == nil
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = 0   
         @eval[q].save
         end
        end
      end

  end
  
  def descriptive
       #@answer.each do|answer|        
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.descriptive_answer = params[:answer_name]
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.evaluate = 1
        evaluation.save
       #end
   end
 
  def evalDescriptive
       #@eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id,@attempt])
       @eval = Evaluation.find_by_categoryuser_id_and_categoryexam_id_and_question_id_and_attempt(@categoryUser,@categoryExam,@question_id,@attempt)

       @answers = Answer.where(["question_id = ?", @question_id]) 
       @question = Question.find_by_id(@question_id)
       @question_mark = @question.mark
       
       @answerCollection = []
       @evalCollection = @eval.descriptive_answer
       @collect_mark = 0
       #@eval.each do |eval|
       # @evalCollection << eval.answer_id
       #end
     
       @answers.each do |answer|
         @answerCollection << answer.name
       end
       
       @evalLength = @answerCollection.length
       
       individualMark = @question_mark/@evalLength
       
      q = 0
      for q in (q ... @evalLength)
         #puts @evalCollection[q].inspect
        #if @answerCollection.include?(@evalCollection[q])
        if @evalCollection.downcase.include?(@answerCollection[q].downcase)
         @collect_mark = @collect_mark + individualMark
         #@eval[q].question_mark = @question.mark
         #@eval[q].answer_mark = individualMark
         #@eval[q].save
        else
         unless @eval == nil
         #@eval[q].question_mark = @question.mark
         #@eval[q].answer_mark = 0
         @collect_mark = @collect_mark + 0   
         #@eval[q].save
         end
        end
      end
       @eval.question_mark = @question.mark
       @eval.answer_mark = @collect_mark
       @eval.save
  end  
  
  
  
  
  def fillups
       
       params[:fields].each do |i, values|
         
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = values["answer_id"]
        evaluation.answer_name = values["name"]
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
       end
       fillupEdit                
    end
    
    def fillupEdit
      @evalCollection = []
       @eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id,@attempt])
       @answers = Answer.where(["question_id = ?", @question_id])
       @question = Question.find_by_id(@question_id)
       @question_mark = @question.mark
       @answerCollection = []
        
       @eval.each do |eval|
        @evalCollection << eval.answer_name.downcase
      end
      
       @answers.each do|answer|
         @answerCollection << answer.name.downcase
       end

       @evalLength = @evalCollection.length
       individualMark = @question_mark/@evalLength
       
      q = 0
      for q in (q ... @evalLength)
        if @evalCollection[q] == @answerCollection[q]
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = individualMark
         @eval[q].save
        else
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = 0   
         @eval[q].save
        end
      end
    end
  
    def hrcl_ordering
      @eval_sort_order = []
      @answer.each do |a|
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = a.to_i
        answer = Answer.find_by_id(a.to_i)
        question = Question.find_by_id(answer.question_id)
        evaluation.answer_name = question.name
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
        @eval_sort_order << a.to_i
       end
   end
   
   def eval_hrcl
     answer_sort_order = []
     @sub_questions = Question.where(["parent_id = ?", params[:question_id].to_i])#.order("sort_order ASC")
     @sub_questions.each do |sq|
       ans = Answer.find_by_question_id(sq.id)
       answer_sort_order << ans.id
     end
     @question = Question.find_by_id(@question_id)
     @question_mark = @question.mark
     @eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id, @attempt])
       
       @evalLength = @eval_sort_order.length
       individualMark = @question_mark/@evalLength

      q = 0
      for q in (q ... @evalLength)
        if answer_sort_order == @eval_sort_order
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = individualMark
         @eval[q].save
        else
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = 0   
         @eval[q].save
        end
      end
   end
 
   def matching
       @answer.each do|a|        
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = a.to_i
        evaluation.has_attended = true
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.attempt = @attempt
        evaluation.save
       end
   end
  
   def evalMatching
     answer_id_order = []
     @sub_questions = Question.where(["parent_id = ?", params[:question_id].to_i])#.order("sort_order ASC")
     @sub_questions.each do |sq|
       ans = Answer.find_by_question_id(sq.id)
       answer_id_order << ans.id
     end
          
      @evalCollection = []
       @eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id,@attempt])
       @question = Question.find_by_id(params[:question_id].to_i)
       @question_mark = @question.mark
       
       @eval.each do |eval|
        @evalCollection << eval.answer_id
      end

       @evalLength = @evalCollection.length
       individualMark = @question_mark/@evalLength

      q = 0
      for q in (q ... @evalLength)
        if answer_id_order[q] == @evalCollection[q]
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = individualMark
         @eval[q].save
        else
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = 0   
         @eval[q].save
        end
      end         
   end
 
   def imageBased
       @answer.each do|answer|        
        evaluation = Evaluation.new
        evaluation.categoryuser_id = params[:categoryuser_id].to_i
        evaluation.question_id = params[:question_id].to_i
        evaluation.answer_id = answer.to_i
        evaluation.categoryexam_id = params[:categoryexam_id].to_i
        evaluation.has_attended = true
        evaluation.attempt = @attempt
        evaluation.save
       end
   end
 
   def eval_imageBased
       @eval = Evaluation.where(["categoryuser_id = ? and categoryexam_id = ? and question_id = ? and attempt = ?",@categoryUser,@categoryExam,@question_id,@attempt])
       @answers = Answer.where(["question_id = ? and is_answer = ?", @question_id,1]) 

       @question = Question.find_by_id(@question_id)
       @question_mark = @question.mark
       
       @answerCollection = []
       @evalCollection = []
       
       @eval.each do |eval|
        @evalCollection << eval.answer_id
       end
     
       @answers.each do |answer|
         @answerCollection << answer.id
       end
       
       @evalLength = @answerCollection.length
       individualMark = @question_mark/@evalLength
      
      q = 0
      for q in (q ... @evalLength)
        if @answerCollection.include?(@evalCollection[q])
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = individualMark
         @eval[q].save
        else
         unless @eval[q] == nil
         @eval[q].question_mark = @question.mark
         @eval[q].answer_mark = 0   
         @eval[q].save
         end
        end
      end
   end
  
end
