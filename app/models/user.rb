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

  has_many :customer_profiles, dependent: :destroy
  has_many :vendor_profiles, dependent: :destroy
  validates :email, presence: true, uniqueness: true ,allow_nil: true 
  validates :password, presence: true, length: { minimum: 6 } , if: :password_required?
  validates :phone_number, uniqueness: true, allow_nil: true
  validate :email_or_phone_present

  # validates :role, presence: true
  # For Google OAuth

  def password_required?
    provider.blank?
  end

  def email_or_phone_present
    if email.blank? && phone_number.blank?
      errors.add(:base, "Either email or phone number must be present")
    end
  end
  # def self.from_google_omniauth(auth)
  #   where(email: auth.info.email).first_or_initialize do |user|
  #     user.email = auth.info.email
  #     user.password = Devise.friendly_token[0, 20]
  #     user.name = auth.info.name
  #     user.save
  #   end
  # end

  def self.find_or_create_from_google(auth)
    puts "find_or_create_from_google"
    return nil unless auth
    puts "auth: #{auth}"
  
    # Extract data safely
    email = auth.info.email
    full_name = auth.info.name || auth.info.full_name
    puts "-----full-name----#{full_name}"
    # image = auth.info.image
    uid   = auth.uid
    provider = auth.provider
    puts "----email-----#{email}"

    # puts image
    puts uid
    puts provider
  
    # 1. Find existing user by provider + uid
    user = User.find_by(provider: provider, uid: uid)
  
    # 2. If not found, find by email
    user ||= User.find_by(email: email)
  
    # 3. Create new user if not found
    unless user
      user = User.create!(
        email: email,
        full_name: full_name,
       
        password: Devise.friendly_token[0, 20],  # Google signup user gets auto password
        provider: provider,
        uid: uid,
 
      )
    end
  
    # 4. Update provider/uid if missing
    if user.provider.nil? || user.uid.nil?
      user.update(provider: provider, uid: uid)
    end
  
    user
  end

  def generate_jwt
    payload = {
      user_id: id,
      email: email,
      exp: 24.hours.from_now.to_i
    }
    
    JWT.encode(payload, Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE'])
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

