class Api::V1::Users::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  protect_from_forgery with: :null_session
  respond_to :json
  puts "inside controller -------"

  FRONTEND_REDIRECT_URL = ENV["FRONTEND_REDIRECT_URL"] || "http://localhost:3000/auth/callback"

  def google_oauth2
      puts "inside controller -------2"
    
    auth = request.env["omniauth.auth"]

    unless auth
      return redirect_to "#{FRONTEND_REDIRECT_URL}?error=no_auth_data"
    end
    puts "inside controller -------3"
    

    user = User.find_or_create_from_google(auth)
    puts "inside controller -------4#{user}"
    if user.persisted?
        puts "inside controller -------5#{user}"
      token = JwtService.encode(user_id: user.id)
              puts "inside controller -------6#{user}"
      redirect_to "#{FRONTEND_REDIRECT_URL}?token=#{token}"
      # render json: { user: user, token: token, message: "Logged in via Google" }, status: :ok
    else
       redirect_to "#{FRONTEND_REDIRECT_URL}?error=oauth_failed"
    end
    

    
  end

  private

  def find_or_create_user(auth)
    email = auth.info.email
    name = auth.info.name
    image = auth.info.image
    google_uid = auth.uid

    user = User.find_by(email: email)

    unless user
      user = User.create!(
        email: email,
        full_name: name,
        google_uid: google_uid,

        password: SecureRandom.hex(10)
      )
    end

    user
  end

  def failure
    redirect_to "#{FRONTEND_REDIRECT_URL}?error=oauth_failed"
  end
end
