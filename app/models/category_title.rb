class CategoryTitle < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => [:category_type_id], :case_sensitive => false, :message=>"Sorry"
  belongs_to :category_type
  has_many :categories
end
