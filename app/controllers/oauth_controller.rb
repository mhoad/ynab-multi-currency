class OauthController < ApplicationController
  before_action :authenticate_user!

  def new
    @authorization_url = oauth.authorization_url
  end

  def index
    oauth.authorize!(params[:code])

    flash[:notice] = "Authorization completed. You're all set!"

    redirect_to conversions_path
  end

  private

  def oauth
    Oauth.new(current_user)
  end
end
