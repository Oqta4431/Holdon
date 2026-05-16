class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    @omniauth = request.env["omniauth.auth"]
    @profile = User.find_or_create_from_omniauth(@omniauth)

    sign_in(:user, @profile)
    flash[:success] = t("omniauth_callbacks.line.success")
    redirect_to root_path

  rescue ArgumentError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    Rails.logger.error "OmniAuth LINE error: #{e.class} - #{e.message}"
    flash[:error] = t("omniauth_callbacks.line.error")
    redirect_to root_path
  end
end
