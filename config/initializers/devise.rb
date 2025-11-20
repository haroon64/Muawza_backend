# config/initializers/devise.rb

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.

# Require the ORM
require 'devise/orm/active_record'

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = Rails.application.credentials.secret_key_base

  # Configure the class responsible to send e-mails.
  config.mailer = 'Devise::Mailer'

  # Configure the parent class responsible to send e-mails.
  config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and :mongoid
  require 'devise/orm/active_record'

  # Other configuration options...
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  # jwt setup
  config.jwt do |jwt|
    jwt.secret = ENV['DEV_JWT_SECRET_KEY']
    jwt.dispatch_requests = [['POST', %r{^/api/v1/signin$}]]
    jwt.revocation_requests = [['DELETE', %r{^/api/v1/signout$}]]
    jwt.expiration_time = 2.hours.to_i
  end
  

config.omniauth :google_oauth2,
  ENV['GOOGLE_CLIENT_ID'],
  ENV['GOOGLE_CLIENT_SECRET'],
  scope: "email,profile",
  prompt: "consent",
  access_type: "offline",
  provider_ignores_state: true


end