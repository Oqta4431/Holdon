class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # /users/sign_up
    # mail+PW以外のパラメータでログインが必要になれば以下の書き方で追加する
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :phone_number, :full_name])
  end
end
