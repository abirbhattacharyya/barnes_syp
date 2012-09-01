class Product < ActiveRecord::Base
  attr_accessible :description, :is_live, :name, :quantity, :regular_price, :target_price, :user_id, :front_image, :back_image, :front_image_remote_url, :back_image_remote_url, :author, :product_type
  attr_accessor :front_image_remote_url, :back_image_remote_url

  TYPES = {
    :nooks => 1,
    :ebooks => 2,
    :combos => 3
  }

  scope :by_product_type, lambda{|type| {:conditions => ["product_type = ?", type] } }

  belongs_to :user
  has_many :offers, :dependent => :destroy
  has_many :payments, :through => :offers

  has_attached_file :front_image, {
    :path => ":rails_root/public/products/:id/:style/front_image/:filename",
    :url => "/products/:id/:style/front_image/:filename",
    :default_url => "/assets/mylogo.jpg"
    #, :styles => { :medium => "90x85>" }
  }
  validates_attachment :front_image, :content_type => {:message => "Hey, Upload a JPEG, GIF, or PNG image please!", :content_type => ["image/jpg", "image/png", "image/gif", "image/bmp", "image/jpeg"] },
    :size => { :in => 0..5.megabytes }

  has_attached_file :back_image, {
    :path => ":rails_root/public/products/:id/:style/back_image/:filename",
    :url => "/products/:id/:style/back_image/:filename",
    :default_url => "/assets/mylogo.jpg"
    #, :styles => { :medium => "90x85>" }
  }
  validates_attachment :back_image, :content_type => {:message => "Hey, Upload a JPEG, GIF, or PNG image please!", :content_type => ["image/jpg", "image/png", "image/gif", "image/bmp", "image/jpeg"] },
    :size => { :in => 0..5.megabytes }

  validates :name, :presence => {:message => "Hey, name can't be blank"}
  # validates :author, :presence => {:message => "Hey, author can't be blank"}
  validates :description, :presence => {:message => "Hey, description can't be blank"}
  validates :regular_price, :presence => {:message => "Hey, price can't be blank"}
  validates :target_price, :presence => {:message => "Hey, minimum price can't be blank"}
  validates :front_image, :presence => {:message => "Hey, image can't be blank"}

  validates_uniqueness_of :name, :scope => [:user_id, :regular_price, :is_live], :message => "Hey, name already been taken"

  validate :valid_price?

  before_validation :download_remote_image, :if => :image_url_provided?

  def color
    self.color_description.gsub(/\d+/, '').strip
  end

  def reg_price
    (self.regular_price.to_f)
  end

  def min_price
    (self.regular_price.to_f*0.3)
  end

  def sold_qty
    return self.payments.map{|p| p.quantity}.sum
  end

  def stock_available?
    return true if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    stock > 0 ? true : false
  end

  def stock_available
    return "Unlimited" if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    return stock
  end

  private
  def valid_price?
    if self.regular_price and self.target_price
      self.errors.add(:quantity, "Hey, quantity should be greater than 0") if self.quantity and self.quantity <= 0
      self.errors.add(:regular_price, "Hey, price should be greater than 0") if self.regular_price <= 0 or self.target_price <= 0
      self.errors.add(:target_price, "Hey, target price should be less than regular price") if self.regular_price < self.target_price
    end
  end

  def image_url_provided?
    (!self.front_image_remote_url.blank? || !self.back_image_remote_url.blank?)
  end

  def download_remote_image
    self.front_image = do_download_remote_image(front_image_remote_url) if !self.front_image_remote_url.blank?
    self.back_image = do_download_remote_image(back_image_remote_url) if !self.back_image_remote_url.blank?
    #self.image_remote_url = image_url
  end

  def do_download_remote_image(url)
    io = open(url)
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  #rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    
  end
end
