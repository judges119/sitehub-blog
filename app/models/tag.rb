class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
  
  validates :url, uniqueness: true
  def to_param
    url
  end
  
  def self.find_by_param(input)
    find_by_url(input)
  end
end
