class ApplicationController < ActionController::Base
  private

  def authorize_ynab!
    if current_user.requires_ynab_authorization?
      redirect_to new_oauth_path
    elsif current_user.requires_ynab_refresh?
      result = Oauth.new(current_user).refresh!

      if result.blank?
        redirect_to new_oauth_path
      end
    end
  end
end
