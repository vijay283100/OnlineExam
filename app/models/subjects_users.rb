class SubjectsUsers < ActiveRecord::Base
  belongs_to :subject_id
  belongs_to :user_id
end
