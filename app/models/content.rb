class Content < ActiveRecord::Base
  mount_uploader :picture, PictureUploader

  belongs_to :post
end
