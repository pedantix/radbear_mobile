class Company < ActiveRecord::Base
  #include Authority::Abilities
  #self.authorizer_name = 'BasicAuthorizer'
  
  validates_lengths_from_database
  validates :email, :name, :phone_number, :website, :address_1, :city, :state, :zipcode, :presence => true
  validate :validate_only_one, :on => :create
                    
  def self.main
    return Company.first
  end
  
  def display_name
    self.name
  end
  
  def full_address
    address = "#{self.address_1}"
    address = "#{address}, #{self.address_2}" if !self.address_2.blank?
    address = "#{address}, #{self.city}, #{self.state} #{self.zipcode}"
    return address
  end
  
  private
  
    def validate_only_one
      errors.add(:base, "Only one company record is allowed.") if Company.count > 0
    end
             
end

