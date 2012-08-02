class FeedbackController < ApplicationController
    filter_access_to :all

  def index
    @arr = [7,8]
    @question_types = QuestionType.where(["id in (?)",@arr])
    if params[:question_type].to_i == 1
    @questions = Question.where(["feedback = ?", 1]).paginate(:page => params[:page], :per_page => 10) 
    elsif params[:question_type].to_i >= 1
    @question_type_id = params[:question_type].to_i
    @questions = Question.where(["question_type_id in (?) and is_published = ? and (parent_id IS NULL or parent_id = ?)", @question_type_id,true,0]).order('created_at desc').paginate(:page => params[:page], :per_page => 10) 
    else
      @questions = Question.where(["question_type_id in (?) and is_published = ? and (parent_id IS NULL or parent_id = ?)", @arr,true,0]).order('created_at desc').paginate(:page => params[:page], :per_page => 10) 
    end
    
  end
  
  
  def assign
   feedbackQuestion = Question.where(["feedback = ?",1])
   if feedbackQuestion.empty?
     @all_published_questions = params[:question]
  
     @all_published_questions.each do|publish|
        @question = Question.find_by_id(publish.to_i)
        @question.update_attributes(:feedback => 1)
      end
       flash[:success] = t('flash_success.ques_published')
    else
       flash[:notice] = t('flash_notice.assigned_state')
    end
     redirect_to :back 
 end
 
 def unassign
   all_published_questions = params[:question]
   publish = all_published_questions.split("_").last
      @question = Question.find_by_id(publish.to_i)
      @question.update_attributes(:feedback => 0)
    render :json => {:text=>true}
 end
 
 def viewFeedback
   arr = [7,8]
   @questions = Question.where(["question_type_id in (?) and feedback = ?",arr,1])
 end

 def submitFeedback
   if params[:question_type_id] == '7'
        feedback = Feedback.new
        feedback.user_id = current_user.id
        feedback.question_id = params[:question_id].to_i
        if feedback.save
          @last = Feedback.find(:last)
        end

        feedback_answer = FeedbackAnswer.new
        feedback_answer.feedback_id = @last.id 
        feedback_answer.answer_id = params[:answerid].to_i
        feedback_answer.question_id = params[:question_id].to_i
        feedback_answer.save
      flash[:success] = t('flash_success.feedback_thanks')
      redirect_to :action=>:index, :controller=>:attend_exams, :user=>@current_user.id
   end
   
   if params[:question_type_id] == '8'     
     unless params[:fields] == nil
     question_ids = params[:seen].collect {|id| id.to_i} if params[:seen]
     quesLeng = question_ids.length
     
      feedback = Feedback.new
      feedback.user_id = current_user.id
      feedback.question_id = params[:parent_question].to_i
      feedback.save
      
      params[:fields].each do |i, values|
        answer_id = values["is_answer"]
        feedback = Feedback.new
        feedback.user_id = current_user.id
        feedback.question_id = question_ids[i.to_i-1]
        if feedback.save
          @last = Feedback.find(:last)
        end
       
        feedback_answer = FeedbackAnswer.new
        feedback_answer.feedback_id = @last.id 
        feedback_answer.answer_id = answer_id.to_i
        feedback_answer.question_id = question_ids[i.to_i-1]
        feedback_answer.save
      end
      flash[:success] = t('flash_success.feedback_thanks')
      redirect_to :action=>:index, :controller=>:attend_exams, :user=>@current_user.id
    else 
      flash[:notice] = t('flash_notice.select_one_option')
      redirect_to :back
    end 
   end

 end
 
 def feedbackResponse
   sql = "SELECT  distinct Q.id 
          FROM       feedbacks F 
          Inner Join questions Q on Q.id = F.question_id;"
    @feedbackResponses = Feedback.find_by_sql(sql)

 end
 
 def viewfeedbackResponse
   @question = Question.find_by_id(params[:question_id].to_i)
   @subQuestions = Question.where(["parent_id = ?",@question.id])
   answers = Answer.find_all_by_question_id(@question.id)
 end

end

