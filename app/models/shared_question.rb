class SharedQuestion < ActiveRecord::Base
  belongs_to :user, :class_name => "User"
  belongs_to :question, :class_name => "Question"
end
