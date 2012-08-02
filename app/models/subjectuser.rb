class Subjectuser < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => [:categorysubject_id]
  belongs_to :user
  belongs_to :subject
  belongs_to :categorysubject
end
