class JwtService
    puts "---------1 #{ENV['DEV_JWT_SECRET_KEY']}"
    SECRET_KEY =  ENV['DEV_JWT_SECRET_KEY']
    puts"---------#{SECRET_KEY}"
    raise "JWT Secret key missing! Set ENV['DEV_JWT_SECRET_KEY']" unless SECRET_KEY.present?


    def self.encode(payload, exp = 24.hours.from_now)
        
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end
  
    def self.decode(token)
    return nil unless token.present?
      body = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
  