require 'oauth/client/action_controller_request'
module OAuthControllerSpecHelper

  def current_user
    @user||=Factory.create(:user)
  end

  def current_client_application
    @client_application||=Factory.create(:client_application, :user => User.find_by_login('mislav')||Factory.create(:mislav))
  end

  def access_token
    @access_token||=AccessToken.create :user=>current_user,:client_application=>current_client_application
  end

  def request_token
    @request_token||=RequestToken.create :client_application=>current_client_application, :callback_url=>"http://application/callback"
  end

  def consumer_request_token
    OAuth::RequestToken.new current_consumer,request_token.token,request_token.secret
  end

  def consumer_access_token
    OAuth::AccessToken.new current_consumer,access_token.token,access_token.secret
  end
  
  def login
    controller.stub!(:current_user).and_return(current_user)
  end

  def login_as_application_owner
    puts "LOGINASOWNER"
    @user = current_client_application.user
    login_as @user
  end

  def current_consumer
    @consumer ||= OAuth::Consumer.new(current_client_application.key,current_client_application.secret,{:site => "http://test.host"})
  end

  def setup_oauth_for_user
    login
  end

  def sign_request_with_oauth(token=nil,options={})
    ActionController::TestRequest.use_oauth=true
    @request.configure_oauth(current_consumer,token,options)
  end

  def two_legged_sign_request_with_oauth(consumer=nil,options={})
    ActionController::TestRequest.use_oauth=true
    @request.configure_oauth(consumer,nil,options)
  end

  def add_oauth2_token_header(token,options={})
    request.env['HTTP_AUTHORIZATION'] = "OAuth #{token.token}"
  end

end
