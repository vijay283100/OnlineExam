class Categoryexamuser < ActiveRecord::Base
  belongs_to :categoryexam
  belongs_to :categoryuser
  serialize   :question_set
end
