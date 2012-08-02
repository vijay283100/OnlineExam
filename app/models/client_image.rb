class ClientImage < ActiveRecord::Base
    has_attached_file :image,
     :styles => {       
     }
  validates_format_of  :image, :with => %r(gif|jpg|png)
end
