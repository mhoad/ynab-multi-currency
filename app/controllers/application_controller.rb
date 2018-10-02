class ApplicationController < ActionController::Base
  private

  def authorize_ynab!
    begin
      if current_user.requires_ynab_authorization?
        return redirect_to new_oauth_path
      end

      yield

    rescue YnabApi::ApiError => e
      e.message == "Unauthorized" || raise
      return redirect_to new_oauth_path
    end
  end
end
