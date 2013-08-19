class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  private
  
  def from_fb
    return if current_user
    begin
      @auth = FbGraph::Auth.new FB_APP_ID, FB_APP_SECRET
      @auth.client.redirect_uri = 'http://localhost:3000/'
      set_auth
      
      if @auth.authorized? or @access_token
        if params[:code]
          fb_user = FbGraph::User.me(@access_token).fetch
        else
          fb_user = @auth.user.fetch
        end
        uid = fb_user.identifier.to_s rescue nil
        @user = User.find_or_initialize_by(uid: uid)
        @user.access_token = @access_token.to_s
        if @user.new_record?
          @user.email = fb_user.email
        end
        @user.password = Devise.friendly_token[0,20]
        @user.save!
        sign_in(@user)
        redirect_to 'https://apps.facebook.com/tav-canvas-app/'
      else
        response.headers["X-Frame-Options"] = "GOFORIT"
        render controller: :home, action: :authorize
      end
    rescue Exception => e
      puts "exception raised"
      puts e.to_json
      redirect_to invalid_path
      return
    end
  end
  
  def set_auth
    raise 'Not from facebook' if !params[:signed_request] and !params[:code]
    
    if params[:code]
      @auth.client.authorization_code = params[:code]
      @access_token = @auth.client.access_token! :client_auth_body
    else
      @auth = @auth.from_signed_request(params[:signed_request])
    end
  end
  
end