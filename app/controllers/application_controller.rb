class ApplicationController < ActionController::Base
  private

  def authorize_ynab!
    if current_user.requires_ynab_authorization?
      redirect_to new_oauth_path
    end
  end
end
