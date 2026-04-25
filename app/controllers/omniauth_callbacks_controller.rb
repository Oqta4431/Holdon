class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    begin
      @omniauth = request.env["omniauth.auth"]
      @profile = User.basic_action(@omniauth)
      sign_in(:user, @profile)
      flash[:notice] = "ログインしました"
      redirect_to root_path
    rescue
      flash[:alert] = "エラーが発生しました、再度やり直してください"
      redirect_to root_path
    end
  end

end
