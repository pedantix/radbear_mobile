class User < ActiveRecord::Base
  include TokenAuthenticatable
  include RadbearUser
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates_lengths_from_database
  validates :username, :uniqueness => true, :allow_nil => true
  validates :first_name, :last_name, :presence => true
  validates :facebook_access_token, length: { maximum: 500 }
  
  has_attached_file :avatar,
    :styles => {:small => "25x25#", :medium => "50x50#", :normal => "100x100#", :large => "200x200#"},
    :storage => :s3,
    :s3_credentials => "#{::Rails.root.to_s}/config/s3.yml",
    :path => "/:class/:attachment/:style/:hash.:extension",
    :hash_secret => "thi5I5My5ecret"
    
  def admin
    return false
  end
end