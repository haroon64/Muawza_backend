module ApiAuthentication
    extend ActiveSupport::Concern
  
    included do
     puts '123'
    end
    
    private
    
    def authenticate_user_from_token!
      token = request.headers['Authorization']&.split(' ')&.last



      if token
        begin
        decoded = JwtService.decode(token)

        rescue => e

          render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
        end
        if decoded

          @current_user = User.find_by(id: decoded[:user_id])

          
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
