class ExamsUsers < ActiveRecord::Base
  belongs_to :exam
  belongs_to :user
  set_primary_key :exam_id
end
