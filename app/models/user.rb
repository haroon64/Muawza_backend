class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         :omniauthable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null,
         omniauth_providers: [:google_oauth2]

  enum :role, { customer: 0, vendor: 1 }

  before_create :set_default_role

  private

  def set_default_role

    self.role ||= :customer
  end

  has_many :customer_profiles, dependent: :destroy
  has_many :vendor_profiles, dependent: :destroy
  validates :email, presence: true, uniqueness: true ,allow_nil: true 
  validates :password, presence: true, length: { minimum: 6 } , if: :password_required?
  validates :phone_number, uniqueness: true, allow_nil: true
  validate :email_or_phone_present

  # validates :role, presence: true
  def password_required?
    new_record? || password.present?
  end

  def email_or_phone_present
    if email.blank? && phone_number.blank?
      errors.add(:base, "Either email or phone number must be present")
    end
  end

  def self.find_or_create_from_google(auth)

    return nil unless auth

    email = auth.info.email
    full_name = auth.info.name || auth.info.full_name
    uid   = auth.uid
    provider = auth.provider
    user = User.find_by(provider: provider, uid: uid)
    user ||= User.find_by(email: email)
  
    unless user
      user = User.create!(
        email: email,
        full_name: full_name,
       
        password: Devise.friendly_token[0, 20], 
        provider: provider,
        uid: uid,
 
      )
    end
  
    if user.provider.nil? || user.uid.nil?
      user.update(provider: provider, uid: uid)
    end
  
    user
  end


  def self.decode_jwt(token)
    decoded = JWT.decode(
      token, 
      Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE']
    ).first
    
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end

