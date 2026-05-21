class PagesController < ApplicationController
  layout -> { user_signed_in? ? "application" : "landing" }, only: [ :terms, :privacy ]

  def onboarding
    return redirect_to home_path if user_signed_in?

    render layout: "landing"
  end

  def terms
  end

  def privacy
  end
end
