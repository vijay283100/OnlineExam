class QuestionsController < ApplicationController
   filter_access_to :all
   
  def index
    @pageCollect = params[:pageLength].to_i
    if @pageCollect == 0
      @pagelength = 10
    else
      @pagelength = params[:pageLength].to_i
    end
    @qId = params[:question_type]
    @question_types = QuestionType.find(:all)
    if current_user.role_id == Admin or current_user.role_id == Examiner
      if params[:question_type].to_i >= 1
      @question_type_id = params[:question_type]
      @questions = Question.where(["question_type_id = ? and (parent_id IS NULL or parent_id = ?)", @question_type_id,0]).paginate(:page => params[:page], :per_page => @pagelength) 
      @question_type = QuestionType.find(params[:question_type].to_i)
      @question_type_name = @question_type.name
      else
      @questions = Question.where(["parent_id IS NULL or parent_id = ?",0]).order("created_at desc").paginate(:page => params[:page], :per_page => @pagelength)
      end
    elsif current_user.role_id == Qsetter
      if params[:question_type].to_i >= 1
        @question_type_id = params[:question_type]
        
        @questions = []
        @ownQuestions=Question.where(["user_id = ? and question_type_id = ? and (parent_id IS NULL or parent_id = ?)",current_user.id,@question_type_id,0])
        @shared_questions=SharedQuestion.where(["user_id = ?",current_user.id])
        @shared_questions.each do|shared_question|
        q = Question.where(["id = ? and is_published = ? and question_type_id = ?", shared_question.question_id,true,@question_type_id])
          unless q.blank?
            s_q = q.first
            @questions << s_q
          end
        end
        @questions = @questions + @ownQuestions
        @questions = @questions.paginate(:page => params[:page], :per_page => @pagelength)
      else
      @questions = []
      @ownQuestions=Question.where(["user_id = ? and (parent_id IS NULL or parent_id = ?)",current_user.id,0])
      @shared_questions=SharedQuestion.where(["user_id = ?",current_user.id])
        @shared_questions.each do|shared_question|
        q = Question.where(["id = ? and is_published = ?", shared_question.question_id,true])
          unless q.blank?
            s_q = q.first
            @questions << s_q
          end
        end
        @questions = @questions + @ownQuestions
        @questions = @questions.paginate(:page => params[:page], :per_page => @pagelength)
      end
    end
  end

  def checkMark
    mark = params[:mark].to_i
    question_id = params[:q_id].to_i
    findQuestion = Examquestion.where(["question_id = ?",question_id])
    if findQuestion.empty?
      render :text => true
    else
      render :text => false
    end
  end  
  
  def question_type_listing
    @qId = params[:q_id].to_i
    @question_types = QuestionType.find(:all)
    unless current_user.role_id == Qsetter
    @category_subject = Categorysubject.find(:all)
    else
    @category_subject = current_user.categorysubjects
    end
  end

  def new
    
    unless params[:subject] == nil and params[:question_type] == nil
     unless params[:subject].to_i == 0
      @category_id = params[:subject]
      @categorySubject = Categorysubject.find_by_id(@category_id.to_i)
      @subject = Subject.find_by_id(@categorySubject.subject_id)
       @users = @categorySubject.users
      if @users.length >= 1
        @users.each do |user|
          if current_user.id == user.id
            @user = user
          end
        end 
      end
     else
        new_question
    end

    if @user != nil
        if current_user.id == @user.id or current_user.role_id == Admin or current_user.role_id == Examiner
            new_question
        else   
            flash[:notice] = t('flash_notice.ques_no_access')
            redirect_to :back
        end
      elsif current_user.role_id == Admin or current_user.role_id == Examiner
        new_question
      else
        flash[:notice] = t('flash_notice.ques_no_access')
        redirect_to :back
    end 
   else
     redirect_to :action=>"question_type_listing"
   end
  end
 
  def new_question
    @count = 3
    @question_type_id = params[:question_type]
    @subject_id = params[:subject]
    @question = Question.new
    if @question_type_id.to_i >= 1
    @question_type = QuestionType.find(params[:question_type].to_i)
    @question_type_name = @question_type.name
    @h_order = [1,2]
    @images = Image.find(:all)
    @image = Image.new
    end
  end
  
  
  def create
    
    if params[:qt_id] == "3"
      question_value
      @seq = 1
      params[:fields].each do |i, values|
      
        u = Answer.new
        u.name = values["name"]
        u.fb_sequence = @seq
        u.question_id = @last.id
        u.save
        @seq=@seq+1
      end
    elsif params[:qt_id] == "12"
      question_value
      @seq = 1
        unless params[:fields] == nil        
         params[:fields].each do |i, values|
           u = Answer.new
           u.name = values["name"]
           u.question_id = @last.id
           u.save
         end
        end
    elsif params[:qt_id] == "10"  
          @question = Question.new
          @question.description = params[:description]
          @question.question_type_id = params[:qt_id]
          @question.user_id = current_user.id
          @question.categorysubject_id = params[:subject_id]
          @question.parent_id = 0
          @question.mark = params[:mark]
           if @question.save
            @last = Question.find(:last)
           end
       params[:fields].each do |i, values|
         @question = Question.new
         @question.question_type_id = params[:qt_id]
         @question.user_id = current_user.id
         @question.categorysubject_id = params[:subject_id]
         @question.name = values["name"]
         @question.parent_id = @last.id
         @question.sort_order = values["is_question_order"]
         @question.save
         @last_for_match = Question.find(:last)

        u = Answer.new
        u.sort_order = values["is_answer_order"]
        u.question_id = @last_for_match.id
        u.save
      end
    elsif params[:qt_id] == '11'
          @question = Question.new
          @question.description = params[:description]
          @question.question_type_id = params[:qt_id]
          @question.user_id = current_user.id
          @question.categorysubject_id = params[:subject_id]
          @question.parent_id = 0
          @question.mark = params[:mark]
           if @question.save
            @last = Question.find(:last)
           end
       params[:fields].each do |i, values|
         @question = Question.new
         @question.question_type_id = params[:qt_id]
         @question.user_id = current_user.id
         @question.categorysubject_id = params[:subject_id]
         @question.name = values["name"]
         @question.parent_id = @last.id
         @question.save
         @last_for_match = Question.find(:last)
         u = Answer.new
         u.match_answer = values["match"]
         u.question_id = @last_for_match.id
         u.save
     end
     
     elsif params[:qt_id] == '8'
          @question = Question.new
          @question.description = params[:description]
          @question.question_type_id = params[:qt_id]
          @question.user_id = current_user.id
          @question.categorysubject_id = params[:subject_id]
          @question.parent_id = 0
           if @question.save
            @last = Question.find(:last)
           end
      
      params[:fields].each do |i, values|
       if values["name"]
         @question = Question.new
         @question.question_type_id = params[:qt_id]
         @question.user_id = current_user.id
         @question.categorysubject_id = params[:subject_id]
         @question.name = values["name"]
         @question.parent_id = @last.id
         @question.save
       end  
      end
       params[:fields].each do |i, values|
        if values["match"]
          u = Answer.new
          u.name = values["match"]
          u.question_id = @last.id
          u.save
        end  
      end
    
    elsif params[:qt_id] == '7'
        question_value
        params[:fields].each do |i, values|     
        u = Answer.new
        u.name = values["name"]
        u.question_id = @last.id
        u.save
      end
    
    elsif params[:qt_id] == '9'
         image_question_value
         @seq = 1
         params[:fields].each do |i, values|
            u = Answer.new
            u.name = values["name"]
            u.is_answer = values["is_answer"] ? 1 : 0
            if values["is_answer"]
              u.fb_sequence = @seq
              @seq = @seq+1
            end
            u.question_id = @last.id
            u.save
        end
        
    elsif params[:qt_id] == '6'
        drag_drop_question_value
        params[:fields].each do |i, values|      
        img = Image.new(values["image"])
        img.save
        last_img = Image.find(:last)
 
        u = Answer.new
        u.is_answer = values["is_answer"] ? 1 : 0
        u.question_id = @last.id
        u.image_id = last_img.id
        u.save
      end
      
    else
        question_value       
        params[:fields].each do |i, values|     
        u = Answer.new
        u.name = values["name"]
        u.is_answer = values["is_answer"] ? 1 : 0
        u.question_id = @last.id
        u.save
      end
   end
      flash[:success] = t('flash_success.question_created')
      redirect_to :controller=>'questions', :action=>'index'    
  end
  
    def question_value
      puts "::::::::::::::::::::::::::::::::"
        puts params[:description].inspect
        @question = Question.new
        @question.description = params[:description]
        @question.question_type_id = params[:qt_id]
        @question.user_id = current_user.id
        @question.categorysubject_id = params[:subject_id]
        @question.mark = params[:mark]
        if @question.save
          @last = Question.find(:last)
        end
    end
    
    def image_question_value        
        @image = Image.new(params[:image])
        @image.save
        @image_last = Image.find(:last)        
        @question = Question.new
        @question.description = params[:description]
        @question.question_type_id = params[:qt_id]
        @question.user_id = current_user.id
        @question.categorysubject_id = params[:subject_id]
        @question.image_id = @image_last.id
        @question.mark = params[:mark]
        if @question.save
          @last = Question.find(:last)
        end
    end
    
    def drag_drop_question_value      
        @image = Image.new(params[:image])
        @image.save
        @image_last = Image.find(:last)      
        @question = Question.new
        @question.description = params[:description]
        @question.question_type_id = params[:qt_id]
        @question.user_id = current_user.id
        @question.categorysubject_id = params[:subject_id]
        @question.image_id = @image_last.id
        @question.mark = params[:mark]
        if @question.save
          @last = Question.find(:last)
        end      
    end
    
  
  def edit
    @questionUser = Question.find_by_id(params[:id])
    if current_user.role_id == Admin or current_user.role_id == Examiner or @questionUser.user_id == current_user.id    
    @question_type_id = params[:qt_id]
    if @question_type_id == '10'
      edit_hrcl_order      
    elsif @question_type_id == '11'
      @question = Question.find(params[:id])
      @sub_questions = Question.where(["parent_id = ?", params[:id]])
      @ans = []
      @sub_questions.each do|sq|
        @answer = Answer.find_by_question_id(sq.id)
        @ans << @answer
      end
    elsif @question_type_id == '8'
     @question = Question.find(params[:id])
     @sub_questions = Question.where(["parent_id = ?", params[:id]])
     @answers = Answer.find_all_by_question_id(@question.id)
    elsif @question_type_id == '9'
     @question = Question.find(params[:id])
     @answers = Answer.find_all_by_question_id(@question.id)
     @image = Image.find(@question.image_id)
     @imageNew = Image.new
    elsif @question_type_id == '6'
     @question = Question.find(params[:id])
     @answers = Answer.find_all_by_question_id(@question.id)
    else
     @question = Question.find(params[:id])
     @answers = Answer.find_all_by_question_id(@question.id)
   end
   else
   flash[:notice] = t('flash_notice.shared_ques_cant_edit')
   redirect_to :back
   end
  end
  
  def edit_hrcl_order
    @h_order = []
    @question = Question.find(params[:id])
    @sub_questions = Question.where(["parent_id = ?", params[:id]])   
    sortArray = []
    @sub_questions.each do|sub|
      sortArray << sub.sort_order
    end
    maxValue = sortArray.max   
    for i in (1..maxValue)
      @h_order << i
    end

    @ans = []
      @sub_questions.each do|sq|
      @answer = Answer.find_by_question_id(sq.id)
      @ans << @answer
      end
  end
  
  
  def update    
    if params[:qt_id] == "1" or params[:qt_id] == "2" or params[:qt_id] == "4" or params[:qt_id] == "5"
       is_answers = params[:is_answer].collect {|id| id.to_i} if params[:is_answer]
       seen_ids = params[:seen].collect {|id| id.to_i} if params[:seen]

        if is_answers
            seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = is_answers.include?(id)
            answer.save
          end
        else
          seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = 0
            answer.save
            end
        end
        
        Answer.update(params[:answer].keys, params[:answer].values)
    
        if params[:fields]
         params[:fields].each do |i, values|
          u = Answer.new
          u.name = values["name"]
          u.is_answer = values["is_answer"] ? 1 : 0
          u.question_id = params[:q_id].to_i
          u.save
         end
        end
    
    elsif params[:qt_id] == "3"
      Answer.update(params[:answer].keys, params[:answer].values)
        if params[:fields]
         params[:fields].each do |i, values|
          u = Answer.new
          u.name = values["name"]
          u.fb_sequence = values["fb_sequence"]
          u.question_id = params[:q_id].to_i
          u.save
         end
     end
     
     
   elsif params[:qt_id] == "9"
   
     unless params[:image] == nil
     @image = Image.new(params[:image])
     @image.save
     @last_image = Image.find(:last)
      @question = Question.find(params[:id].to_i)
      @question.description = params[:question][:description]
      @question.image_id = @last_image.id
      @question.save     
     else
      @question = Question.find(params[:id].to_i)
      @question.description = params[:question][:description]
      @question.mark = params[:mark]
      @question.save
     end
       is_answers = params[:is_answer].collect {|id| id.to_i} if params[:is_answer]
       seen_ids = params[:seen].collect {|id| id.to_i} if params[:seen]

        if is_answers
            seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = is_answers.include?(id)
            answer.save
          end
        else
          seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = 0
            answer.save
            end
        end
       Answer.update(params[:answer].keys, params[:answer].values)
    
        if params[:fields]
          params[:fields].each do |i, values|
          u = Answer.new
          u.name = values["name"]
          u.is_answer = values["is_answer"] ? 1 : 0
          u.question_id = params[:q_id].to_i
          u.save
         end
     end
        flash[:success] = t('flash_success.question_updated')
        redirect_to :action=>'index'
        
   elsif params[:qt_id] == "6"     
     unless params[:image] == nil
     @image = Image.new(params[:image])
     @image.save
     @last_image = Image.find(:last)
      @question = Question.find(params[:id].to_i)
      @question.description = params[:question][:description]
      @question.image_id = @last_image.id
      @question.save
     else
      @question = Question.find(params[:id].to_i)
      @question.description = params[:question][:description]
      @question.mark = params[:mark]
      @question.save
     end
     
     if params[:fields]
       params[:fields].each do |i, values|        
        unless values["update_image"] == nil
          @image = Image.new(values["update_image"])
          @image.save
          @last_image = Image.find(:last)
          ans = Answer.find(i)
          ans.image_id = @last_image.id
          ans.is_answer = values["is_answer"] ? 1 : 0
          ans.save
        end 
                unless values["image"] == nil
        img = Image.new(values["image"])
        img.save
        last_img = Image.find(:last)
        u = Answer.new
        u.is_answer = values["is_answer"] ? 1 : 0
        u.question_id = params[:q_id].to_i
        u.image_id = last_img.id
        u.save
        end
      end
    end
       is_answers = params[:is_answer].collect {|id| id.to_i} if params[:is_answer]
       seen_ids = params[:seen].collect {|id| id.to_i} if params[:seen]
        if is_answers
            seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = is_answers.include?(id)
            answer.save
          end
        else
          seen_ids.each do |id|
            answer = Answer.find_by_id(id)
            answer.is_answer = 0
            answer.save
            end
        end
  
    elsif params[:qt_id] == "7" or params[:qt_id] == "12"
       unless params[:answer] == nil
        Answer.update(params[:answer].keys, params[:answer].values)
        if params[:fields]
         params[:fields].each do |i, values|
          u = Answer.new
          u.name = values["name"]
          u.question_id = params[:q_id].to_i
          u.save
         end
        end
       end
       
    elsif params[:qt_id] == "10"
      Question.update(params[:answer].keys, params[:answer].values)
      Answer.update(params[:answerOrder].keys, params[:answerOrder].values)
      
            if params[:fields] 
             params[:fields].each do |i, values|
                @question = Question.new
                @question.question_type_id = params[:qt_id]
                @question.user_id = current_user.id
                @question.categorysubject_id = params[:subject_id]
                @question.name = values["name"]
                @question.parent_id = params[:parent_id]
                @question.sort_order = values["is_question_order"]
                @question.save
                @last_for_match = Question.find(:last)
                u = Answer.new
                u.sort_order = values["is_answer_order"]
                u.question_id = @last_for_match.id
                u.save
             end
            end
      
    elsif params[:qt_id] == "11"
      Question.update(params[:answer].keys, params[:answer].values)
      Answer.update(params[:answerOrder].keys, params[:answerOrder].values)
      
      if params[:fields]
         params[:fields].each do |i,values|
            
           @question = Question.new
           @question.question_type_id = params[:qt_id]
           @question.user_id = current_user.id
           @question.categorysubject_id = params[:subject_id]
           @question.name = values["name"]
           @question.parent_id = params[:parent_id]
           @question.save
           @last_for_match = Question.find(:last)
           u = Answer.new
           u.match_answer = values["match"]
           u.question_id = @last_for_match.id
           u.save
            
         end
     end
     
     elsif params[:qt_id] == "8"
      Question.update(params[:answer].keys, params[:answer].values)
      Answer.update(params[:answerOrder].keys, params[:answerOrder].values)
      
       if params[:fields]
       params[:fields].each do |i, values|
       if values["name"]
         @question = Question.new
         @question.question_type_id = params[:qt_id]
         @question.user_id = current_user.id
         @question.categorysubject_id = params[:subject_id]
         @question.name = values["name"]
         @question.parent_id = params[:parent_id]
         @question.save
       end  
      end
       params[:fields].each do |i, values|
        if values["match"]
          u = Answer.new
          u.name = values["match"]
          u.question_id = params[:parent_id]
          u.save
        end  
      end
     end
    end
    
    unless params[:qt_id] == "9"
      @question = Question.find(params[:id].to_i)
      @question.description = params[:question][:description]
      @question.mark = params[:mark]
      if @question.save
        flash[:success] = t('flash_success.question_updated')
        redirect_to :action=>'index'
      end
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    @sub_questions = Question.find_all_by_parent_id(@question.id)
    @answer = @question.answers
    if current_user.role_id == Admin or current_user.role_id == Examiner or @question.user_id == current_user.id
        evaluations = Evaluation.where(["question_id = ?", @question.id])
        examquestions = Examquestion.where(["question_id = ?", @question.id])
        
        if evaluations.empty? and examquestions.empty?
          if @sub_questions
             @sub_questions.each do|sq|
               sq.destroy
             end
           end
           
           if @answer
              @question.answers.delete(@answer)
           end
        
            @question.destroy
            flash[:success] = t('flash_success.question_deleted')
            redirect_to :back
        else
          flash[:notice] = t('flash_notice.cant_del_ques')
          redirect_to :back
        end
    else
      flash[:notice] = t('flash_notice.shard_ques_cant_del')
      redirect_to :back
    end

  end
  
  def delete_option
    @answers = Answer.find_all_by_question_id(params[:question_id].to_i)
    ans_length = @answers.length
  if params[:question_id] == '3'
    if ans_length > 1
    @answer_option = Answer.find(params[:id])
    @answer_option.destroy
    flash[:success] = t('flash_success.ques_ops_deleted')
    else
    flash[:notice] = t('flash_notice.req_one')
    end    
  else
    if ans_length > 2
    @answer_option = Answer.find(params[:id])
    @answer_option.destroy
    flash[:success] = t('flash_success.ques_ops_deleted')
    else
    flash[:notice] = t('flash_notice.req_two')
    end
  end
  redirect_to :back
  end
  
  def delete_match_option
    @sub_questions = Question.where(["parent_id = ?", params[:question_id].to_i])
    if @sub_questions.length > 2
    @answer_option = Answer.find(params[:id])
    @question_option = Question.find(@answer_option.question_id)
    @answer_option.destroy and @question_option.destroy
    flash[:success] = t('flash_success.ques_ops_deleted')
    else
      flash[:notice] = t('flash_notice.req_two')
    end
    redirect_to :back
  end
  
  def delete_hrcl_option
    @sub_questions = Question.where(["parent_id = ?", params[:question_id].to_i])
    if @sub_questions.length > 2
       @answer_option = Answer.find(params[:id])
       @question_option = Question.find(@answer_option.question_id)
       @answer_option.destroy and @question_option.destroy
       flash[:success] = t('flash_success.ques_ops_deleted')
    else
      flash[:notice] = t('flash_notice.req_two')
    end
    redirect_to :back
  end
  
  def delete_matrix_row
    @sub_questions = Question.where(["parent_id = ?", params[:question_id].to_i])
    if @sub_questions.length > 2
    @question_option = Question.find(params[:id])
    @question_option.destroy
    flash[:success] = t('flash_success.ques_ops_deleted')
    else
      flash[:notice] = t('flash_notice.req_two')
    end
    redirect_to :back

  end
  
  def delete_matrix_column
    @sub_questions = Answer.where(["question_id = ?", params[:question_id].to_i])
    if @sub_questions.length > 2
    @answer_option = Answer.find(params[:id])
    @answer_option.destroy
    flash[:success] = t('flash_success.ques_ops_deleted')
    else
      flash[:notice] = t('flash_notice.req_two')
    end
    redirect_to :back
  end

def publish_unpublish
   @all_published_questions = params[:question]
   @all_published_questions.each do|publish|
      @question = Question.find_by_id(publish.to_i)
      @question.update_attributes(:is_published => 1)
    end
     flash[:success] = t('flash_success.ques_published')
        redirect_to :back 
 end
 
 def unpublish
   all_published_questions = params[:question]
   publish = all_published_questions.split("_").last
      @question = Question.find_by_id(publish.to_i)
      @question.update_attributes(:is_published => 0)
    render :text => true
 end
 
 
 
 def sharewithCategory
   @shared_question = params[:share]
   @shared_question = @shared_question.split("_").last
   @quesUser = Question.find_by_id(@shared_question) 
   @userId = User.find_by_id(@quesUser.user_id) 
   @users=User.where(["(role_id = ? and id != ? and id != ?)",Qsetter,current_user.id,@userId]).order("created_at desc")
   render :layout => false
 end
 
  def share
    if params[:user_id].to_i >= 1
      user_id= params[:user_id].to_i
      question_id = params[:question_id].to_i
      question = Question.find_by_id(question_id)
      user = User.find_by_id(user_id)
       question.users << user
       question.save
       flash[:success] = t('flash_success.ques_shared')
       redirect_to :back
    else
     flash[:notice] = t('flash_notice.ques_qsetter')
     redirect_to :back
    end
     rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
     flash[:notice] = t('flash_notice.already_shared')
     redirect_to :back
  end

  def viewQuestion
   @question = Question.find_by_id(params[:question].to_i)
  end
  
end
