class Question < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
    require 'prawn'
  has_many :examquestion
  has_many :exams, :through => :examquestion
  
  has_many :shared_question
  has_many :users, :through => :shared_question
  
  belongs_to :categorysubject
  
  belongs_to :user
  has_one :evaluation
  belongs_to :subject
  belongs_to :question_type
  belongs_to :image
  has_many :answers, :dependent => :destroy
  
  
  Selector_type = [["1","Recent Questions"],
              ["2","Old Questions"],
              ["3","Reacently Updated"],
              ["4","Last updated"]]
              
  Selector_types = Selector_type.freeze
  
  
  def collect_subject(id)
    if id != nil
    @cat = Categorysubject.find_by_id(id)
    @cat = @cat.subject_id
    @subject = Subject.find_by_id(@cat)
    @subjectName = @subject.name
    return @subjectName
    end
  end
  
  def getCount(question,answer)
    
    sql = "SELECT  distinct Count(answer_id) as totCount 
          FROM       feedback_answers F 
          Inner Join questions Q on Q.id = F.question_id
          Inner Join answers A on A.id = F.answer_id
          where F.question_id = #{question} and F.answer_id = #{answer}
          Group By F.question_id,F.answer_id;"
    @feedbackResponse = FeedbackAnswer.find_by_sql(sql)
    
    @feedbackResponse.each do|feedbackCount|
      return feedbackCount.totCount
    end
    
   end
  
   def checkMark(q_id)
    findQuestion = Examquestion.where(["question_id = ?",q_id])
    if findQuestion.empty?
      return 1
    else
      return 0
    end
  end
  
    def descriptive_model(text)
      puts "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
      puts text.inspect
    strip_tags(text)#.to_s.gsub(/(<[^>]+>|&nbsp;|\r|\n|&prod;|<sup>)/,"")
    #text.to_s.gsub(/(<[^>]+>|&nbsp;|\r|\n|&prod;|<sup>)/,"")
    end
  
    def des(text)
      
      pdftable = Prawn::Document.new
      pdftable.table([["#{text}"]],:column_widths => {0 => 50, 1 => 60, 2 => 280, }, :row_colors => ["ffffff"])
         
      send_data pdftable.render, :filename=>"userReport.pdf", :type=>"application/pdf"
    end
end
