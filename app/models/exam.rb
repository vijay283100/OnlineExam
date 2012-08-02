class Exam < ActiveRecord::Base

  has_many :examquestion
  has_many :questions, :through => :examquestion

  has_one :exam_result
  has_one :evaluation
  
  has_many :categoryexam
  has_many :categories, :through => :categoryexam
  
  has_many :evaluate_exams
  has_many :users, :through=> :evaluate_exams
  
  def has_attended(e_id)
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
      return 1
    else
      return 0
    end
    
  end
  
  def tempCount(u)
    sql = "SELECT COUNT(U.is_temp_examinee)AS TempExamineeCount
          FROM  categoryexamusers Q 
          Inner Join categoryusers D on Q.categoryuser_id = D.id
          Inner Join categoryexams C on Q.categoryexam_id = C.id
          Inner Join users U on D.user_id = U.id
          Inner Join exams S on C.exam_id = S.id WHERE S.id = #{u} AND U.is_temp_examinee=1"
          
          @temp_examinees = User.find_by_sql(sql)
            @temp_examinees.each do|t|
              @count = t.TempExamineeCount
          end
          if @count.to_i == 0
            return 0
          else
            return @count
          end
  end
  
  
end
