class User < ActiveRecord::Base
	has_many :students, -> { order(:first_name) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:facebook, :twitter]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name
  # attr_accessible :title, :body

  validates_uniqueness_of    	:email,    	:case_sensitive => false, :allow_blank => true, :if => :email_changed?
  validates_format_of 				:email, 		:with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of   		:password, 	:on=>:create
  validates_confirmation_of   :password, 	:on=>:create
  validates_length_of 				:password, 	:within => Devise.password_length, :allow_blank => true

	def self.find_or_create_from_oauth(auth, signed_in_resource=nil)
	  user = User.where(:provider => auth.provider, :uid => auth.uid).first
	  if user.blank?
	    user = User.create!(name: auth.extra.raw_info.name,
	                         provider: auth.provider,
	                         uid: auth.uid,
	                         email: auth.info.email,
	                         password: Devise.friendly_token[0,20]
	                         )
	  end
	  return user
	end
end
