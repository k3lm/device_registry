class ApplicationController < ActionController::API
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    api_key = ApiKey.find_by(token: token)
    @current_user = api_key&.bearer
    head :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end