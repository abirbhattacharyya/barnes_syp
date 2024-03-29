class User < ActiveRecord::Base
  attr_accessible :email, :is_blocked, :password, :remember_token, :remember_token_epires_at

  has_one :profile, :dependent => :destroy
  has_many :products, :dependent => :destroy
  
  validates :email, :presence => {:message => "^Hey, email can't be blank"}
  validates :password, :presence => {:message => "^Hey, password can't be blank"}

  validates_format_of :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_uniqueness_of :email, :case_sensitive => false, :if => :email, :message => "^Hey, incorrect email/password combination."

  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and password=?', email, password] # need to get the salt
    return u
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

	def self.verify_user(email, dt="dealkat")
		Digest::SHA256.hexdigest("#{email}#{dt}")
	end
end
