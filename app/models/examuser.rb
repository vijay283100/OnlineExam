class Examuser < ActiveRecord::Base
    belongs_to :exam
  belongs_to :user
  serialize   :question_set
end
