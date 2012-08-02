class Evaluation < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :question
  belongs_to :answer
  belongs_to :exam
   
  def evalId(q_id,exam_id,u_id)
    @eval = Evaluation.find_by_question_id_and_exam_id_and_user_id_and_has_attended(q_id,exam_id.id,u_id.id,true)
    return @eval.id
  end
end
