module ApiAuthentication
    extend ActiveSupport::Concern
  
    included do
      before_action :authenticate_user_from_token!
    end
    
    private
    
    def authenticate_user_from_token!
      token = request.headers['Authorization']&.split(' ')&.last

      puts "----token#{token}"

      if token
        begin
        decoded = JwtService.decode(token)

        rescue => e
          puts "---Decode Error: #{e.message}"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
        end
        puts "---#{decoded}"
        if decoded

            
          @current_user = User.find_by(id: decoded[:user_id])
          puts "-----#{current_user}"
          
          unless @current_user
            render json: { error: 'User not found' }, status: :unauthorized
          end
        else
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
        end
      else
        render json: { error: 'No token provided' }, status: :unauthorized
      end
    end
    
    def current_user
      @current_user
    end
  end