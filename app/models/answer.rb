class Answer < ActiveRecord::Base
  has_many :evaluations
  belongs_to :image
  belongs_to :question
  

    def getCount(answer,question)
    
    sql = "SELECT  distinct Count(answer_id) as totCount 
          FROM       feedback_answers F 
          Inner Join questions Q on Q.id = F.question_id
          Inner Join answers A on A.id = F.answer_id
          where F.question_id = #{question.id} and F.answer_id = #{answer.id}
          Group By F.question_id,F.answer_id;"
    @feedbackResponse = FeedbackAnswer.find_by_sql(sql)
    
    @feedbackResponse.each do|feedbackCount|
      return feedbackCount.totCount
    end
    
  end
  
end
